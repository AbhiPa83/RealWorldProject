# AWS Configuration
aws_region  = "ap-south-1"
environment = "production"
project_name = "RealWorldApp"

# VPC Configuration
vpc_cidr               = "192.168.0.0/16"
public_subnet_1a_cidr  = "192.168.1.0/24"
public_subnet_1b_cidr  = "192.168.2.0/24"
private_subnet_1a_cidr = "192.168.3.0/24"
private_subnet_1b_cidr = "192.168.4.0/24"
db_subnet_cidr         = "192.168.5.0/24"

# Availability Zones
az_1 = "ap-south-1a"
az_2 = "ap-south-1b"

# EC2 Configuration
# ami_id = "ami-0c02fb55db41efb5b"  # Amazon Linux 2 in ap-south-1
instance_type         = "t3.micro"
bastion_instance_type = "t3.micro"
key_pair_name         = "LinuxTest"

# Auto Scaling Group Configuration
asg_min_size        = 3
asg_max_size        = 6
asg_desired_capacity = 3

# Database Configuration
db_identifier           = "app-mysql-db"
db_name                 = "appdb"
db_username             = "admin"
db_password             = "ChangeMe@123"  # CHANGE THIS to a strong password
db_instance_class       = "db.t3.micro"
db_engine_version       = "8.0"
allocated_storage       = 20
backup_retention_period = 7
rds_multi_az            = true
rds_deletion_protection = true
skip_final_snapshot     = false
