variable "region" {
  default = "ap-south-1"
}

variable "key_name" {
  default = "Linux_Key"
}

variable "db_password" {
  sensitive = true
}