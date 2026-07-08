resource "aws_launch_template" "this" {
  name          = "${var.name}-tpl"
  image_id      = var.image_id
  instance_type = var.instance_type 
  key_name      = var.key_name != null ? var.key_name : null
  
  # user_data codificado en base64 para Launch Templates
  user_data     = filebase64("${path.module}/install.sh")

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge({ "ResourceName" = "${var.name}-tpl" }, var.tags)
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type
  
  # 🔄 CORREGIDO: Usamos la lista de IDs reales de subredes
  vpc_zone_identifier       = var.subnet_ids
  
  # Target Groups donde el ASG va a registrar las instancias dinámicamente
  target_group_arns         = var.target_group_arns

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
  
  
}

# ----------------------------------------------------
# Politicas de Escalado y Alarma Up
# ----------------------------------------------------
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.name}-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "${var.name}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.this.name
  }
  
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
}

# ----------------------------------------------------
# Politicas de Escalado y Alarma Down
# ----------------------------------------------------
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.name}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${var.name}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 5
  
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.this.name
  }
  
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}