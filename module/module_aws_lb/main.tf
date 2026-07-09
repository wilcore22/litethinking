resource "aws_lb" "this" {
  name               = var.name_lb
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_group_ids
  
  
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge({ "Name" = var.name_lb }, var.tags)
}

resource "aws_lb_target_group" "this" {
  name        = "tg-${var.name_lb}"
  port        = var.lb_target_port
  protocol    = var.lb_protocol    
  target_type = var.lb_target_type  
  vpc_id      = var.vpc_id
  
  tags        = merge({ "Name" = "tg-${var.name_lb}" }, var.tags)
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
  count            = length(var.target_instance_ids)
  target_group_arn = aws_lb_target_group.this.arn
  
  
  target_id        = var.target_instance_ids[count.index]
  port             = var.lb_target_port
}