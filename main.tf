terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      CreatedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr               = var.vpc_cidr
  public_subnet_1a_cidr  = var.public_subnet_1a_cidr
  public_subnet_1b_cidr  = var.public_subnet_1b_cidr
  private_subnet_1a_cidr = var.private_subnet_1a_cidr
  private_subnet_1b_cidr = var.private_subnet_1b_cidr
  db_subnet_cidr         = var.db_subnet_cidr
  az_1                   = var.az_1
  az_2                   = var.az_2
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id = module.vpc.vpc_id
}

# IAM Role and Instance Profile (for EC2)
resource "aws_iam_role" "ec2_role" {
  name = "ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "EC2-App-Role"
  }
}

# Attach policy for CloudWatch and SSM
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-app-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  bastion_instance_type     = var.bastion_instance_type
  instance_profile_name     = aws_iam_instance_profile.ec2_profile.name
  public_subnet_id          = module.vpc.public_subnet_1a_id
  bastion_security_group_id = module.security_groups.bastion_sg_id
  ec2_security_group_id     = module.security_groups.ec2_sg_id
  key_pair_name             = var.key_pair_name
  db_endpoint               = module.rds.db_address
  db_user                   = var.db_username
  db_password               = var.db_password
  db_name                   = var.db_name
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  vpc_id                  = module.vpc.vpc_id
  alb_security_group_id   = module.security_groups.alb_sg_id
  public_subnet_ids       = [module.vpc.public_subnet_1a_id, module.vpc.public_subnet_1b_id]
}

# Autoscaling Module
module "autoscaling" {
  source = "./modules/autoscaling"

  launch_template_id  = module.ec2.launch_template_id
  private_subnet_ids  = [module.vpc.private_subnet_1a_id, module.vpc.private_subnet_1b_id]
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  target_group_arns   = [module.alb.target_group_arn]
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  db_subnet_ids              = [module.vpc.db_subnet_id]
  mysql_security_group_id    = module.security_groups.mysql_sg_id
  db_identifier              = var.db_identifier
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
  db_instance_class          = var.db_instance_class
  db_engine_version          = var.db_engine_version
  allocated_storage          = var.allocated_storage
  backup_retention_period    = var.backup_retention_period
  multi_az                   = var.rds_multi_az
  deletion_protection        = var.rds_deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
}
