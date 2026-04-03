output "bastion_sg_id" {
  description = "Bastion Security Group ID"
  value       = aws_security_group.bastion_sg.id
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb_sg.id
}

output "ec2_sg_id" {
  description = "EC2 Security Group ID"
  value       = aws_security_group.ec2_sg.id
}

output "mysql_sg_id" {
  description = "MySQL Security Group ID"
  value       = aws_security_group.mysql_sg.id
}
