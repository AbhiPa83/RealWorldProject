# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

# Subnet Outputs
output "public_subnet_1a_id" {
  description = "Public Subnet AZ1 ID"
  value       = module.vpc.public_subnet_1a_id
}

output "public_subnet_1b_id" {
  description = "Public Subnet AZ2 ID"
  value       = module.vpc.public_subnet_1b_id
}

output "private_subnet_1a_id" {
  description = "Private Subnet AZ1 ID"
  value       = module.vpc.private_subnet_1a_id
}

output "private_subnet_1b_id" {
  description = "Private Subnet AZ2 ID"
  value       = module.vpc.private_subnet_1b_id
}

output "db_subnet_id" {
  description = "Database Subnet ID"
  value       = module.vpc.db_subnet_id
}

# Security Group Outputs
output "bastion_security_group_id" {
  description = "Bastion Security Group ID"
  value       = module.security_groups.bastion_sg_id
}

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = module.security_groups.alb_sg_id
}

output "ec2_security_group_id" {
  description = "EC2 Security Group ID"
  value       = module.security_groups.ec2_sg_id
}

output "mysql_security_group_id" {
  description = "MySQL Security Group ID"
  value       = module.security_groups.mysql_sg_id
}

# EC2 Outputs
output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = module.ec2.bastion_public_ip
}

output "bastion_instance_id" {
  description = "Bastion Host Instance ID"
  value       = module.ec2.bastion_instance_id
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = module.ec2.launch_template_id
}

# ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS Name - Access your application via this URL"
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = module.alb.target_group_arn
}

# Auto Scaling Outputs
output "asg_name" {
  description = "Auto Scaling Group Name"
  value       = module.autoscaling.asg_name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = module.autoscaling.asg_arn
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS Database Endpoint"
  value       = module.rds.db_endpoint
}

output "rds_address" {
  description = "RDS Database Address"
  value       = module.rds.db_address
  sensitive   = true
}

output "rds_port" {
  description = "RDS Database Port"
  value       = module.rds.db_port
}

output "rds_identifier" {
  description = "RDS Database Identifier"
  value       = module.rds.db_identifier
}

# Access Information
output "access_info" {
  description = "Access Information"
  value = {
    application_url = "http://${module.alb.alb_dns_name}"
    bastion_ip      = module.ec2.bastion_public_ip
    database_host   = module.rds.db_address
    database_port   = module.rds.db_port
  }
}
