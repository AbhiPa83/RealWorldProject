variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

# variable "certificate_arn" {
#   description = "SSL certificate ARN for HTTPS"
#   type        = string
#   default     = ""
# }
