output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "ARN del Target Group para conectar instancias o ASG"
}

output "lb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "URL publica del Load Balancer"
}