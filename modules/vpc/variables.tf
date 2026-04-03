variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_1a_cidr" {
  description = "CIDR block for public subnet in AZ1"
  type        = string
  default     = "192.168.1.0/24"
}

variable "public_subnet_1b_cidr" {
  description = "CIDR block for public subnet in AZ2"
  type        = string
  default     = "192.168.2.0/24"
}

variable "private_subnet_1a_cidr" {
  description = "CIDR block for private subnet in AZ1"
  type        = string
  default     = "192.168.3.0/24"
}

variable "private_subnet_1b_cidr" {
  description = "CIDR block for private subnet in AZ2"
  type        = string
  default     = "192.168.4.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR block for database subnet"
  type        = string
  default     = "192.168.5.0/24"
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