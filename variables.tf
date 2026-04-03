# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# Project Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "RealWorldApp"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_1a_cidr" {
  description = "Public subnet AZ1 CIDR"
  type        = string
  default     = "192.168.1.0/24"
}

variable "public_subnet_1b_cidr" {
  description = "Public subnet AZ2 CIDR"
  type        = string
  default     = "192.168.2.0/24"
}

variable "private_subnet_1a_cidr" {
  description = "Private subnet AZ1 CIDR"
  type        = string
  default     = "192.168.3.0/24"
}

variable "private_subnet_1b_cidr" {
  description = "Private subnet AZ2 CIDR"
  type        = string
  default     = "192.168.4.0/24"
}

variable "db_subnet_cidr" {
  description = "Database subnet CIDR"
  type        = string
  default     = "192.168.5.0/24"
}

variable "db_subnet_1a_cidr" {
  description = "CIDR block for database subnet in AZ1"
  type        = string
  default     = "192.168.5.0/24"
}

variable "db_subnet_1b_cidr" {
  description = "CIDR block for database subnet in AZ2"
  type        = string
  default     = "192.168.6.0/24"
}

variable "az_1" {
  description = "First Availability Zone"
  type        = string
  default     = "ap-south-1a"
}

variable "az_2" {
  description = "Second Availability Zone"
  type        = string
  default     = "ap-south-1b"
}

# EC2 Configuration
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c02fb55db41efb5b" # Amazon Linux 2 in ap-south-1
}

variable "instance_type" {
  description = "Instance type for application servers"
  type        = string
  default     = "t3.micro"
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "" # MUST BE SET - create using: aws ec2 create-key-pair --key-name <key-name> --region ap-south-1
}

# Auto Scaling Configuration
variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 3
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 3
}

# Database Configuration
variable "db_identifier" {
  description = "Database identifier"
  type        = string
  default     = "app-mysql-db"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master database username"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "db_password" {
  description = "Master database password (CHANGE THIS!)"
  type        = string
  sensitive   = true
  default     = "ChangeMe@123"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 0  # Changed to 0 for free tier compatibility
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = false  # Disabled for free tier
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on delete"
  type        = bool
  default     = false
}
