output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.app_alb.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.app_alb.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app_alb.dns_name
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.app_tg.arn
}

output "target_group_name" {
  description = "Target Group name"
  value       = aws_lb_target_group.app_tg.name
}
