variable "db_subnet_ids" {
  description = "List of database subnet IDs"
  type        = list(string)
}

variable "mysql_security_group_id" {
  description = "Security group ID for MySQL"
  type        = string
}

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
  description = "Master database password"
  type        = string
  sensitive   = true
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

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false  # Disabled for free tier
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on delete"
  type        = bool
  default     = false
}
