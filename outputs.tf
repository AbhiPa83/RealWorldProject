output "alb_dns" {
  value = module.alb.alb_dns
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "bastion_ip" {
  value = module.bastion.public_ip
}