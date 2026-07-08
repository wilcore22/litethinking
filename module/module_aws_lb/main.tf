resource "aws_lb" "this" {
  name               = var.name_lb
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_cidrs

  enable_deletion_protection = var.enable_deletion_protection #true

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = merge({ "Name" = var.name_lb }, var.tags)
}

resource "aws_lb_target_group" "this" {
  name        = "tg-${var.name_lb}"
  port        = var.lb_target_port
  protocol    = var.lb_protocol    
  target_type = var.lb_target_type  
  vpc_id      = var.vpc_id
  tags        = merge({ "Name" = "tg-${var.name_lb}" }, var.tags)
  depends_on  = [aws_lb.this]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.lb_listener_port     
  protocol          = var.lb_listener_protocol 


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count            = length(data.aws_instances.this.ids)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = data.aws_instances.this.ids[count.index] #data.aws_instance.this.id
  port             = var.lb_target_port                       # 80
}





