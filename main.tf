provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source = "./modules/subnets"

  vpc_id          = module.vpc.vpc_id
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "sg" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

module "nat" {
  source           = "./modules/nat_gateway"
  public_subnet_id = module.subnets.public_subnets[0]
}

module "bastion" {
  source    = "./modules/bastion"
  subnet_id = module.subnets.public_subnets[0]
  sg_id     = module.sg.bastion_sg
  key_name  = var.key_name
}

module "alb" {
  source  = "./modules/alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.subnets.public_subnets
  sg_id   = module.sg.alb_sg
}

module "rds" {
  source     = "./modules/rds"
  db_subnets = module.subnets.private_subnets
  vpc_id     = module.vpc.vpc_id
  sg_id      = module.sg.rds_sg

  db_name  = "mydb"
  username = "admin"
  password = var.db_password
}

module "launch_template" {
  source      = "./modules/launch_template"
  sg_id       = module.sg.app_sg
  key_name    = var.key_name
  db_endpoint = module.rds.endpoint
}

module "asg" {
  source       = "./modules/asg"
  lt_id        = module.launch_template.lt_id
  subnets      = module.subnets.private_subnets
  target_group = module.alb.target_group_arn
}