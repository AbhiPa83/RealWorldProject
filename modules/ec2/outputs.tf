output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.app_launch_template.id
}

output "launch_template_latest_version" {
  description = "Launch Template latest version"
  value       = aws_launch_template.app_launch_template.latest_version
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Bastion Host Instance ID"
  value       = aws_instance.bastion.id
}
