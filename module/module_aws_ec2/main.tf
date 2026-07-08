resource "aws_instance" "this" {
  ami                         = var.ami 
  instance_type               = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = var.azs[1]
  
  subnet_id                   = var.subnet_ids[1] 
  
  vpc_security_group_ids      = var.security_group_ids
  user_data                   = templatefile(var.user_data_filepath, {})
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  disable_api_termination     = var.disable_api_termination
  
  root_block_device {
    volume_size           = 10         
    volume_type           = "gp3"      
    delete_on_termination = true       
  }
}



resource "aws_cloudwatch_metric_alarm" "this" {

  alarm_name                = "cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120" #seconds
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.this.id
  }

}