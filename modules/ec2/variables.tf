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

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for bastion host"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  type        = string
}

variable "ec2_security_group_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "db_endpoint" {
  description = "Database endpoint URL"
  type        = string
  default     = ""
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "myappdb"
}
