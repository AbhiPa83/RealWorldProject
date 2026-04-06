variable "db_subnets" { type = list(string) }
variable "vpc_id" {}
variable "sg_id" {}
variable "db_name" {}
variable "username" {}
variable "password" { sensitive = true }