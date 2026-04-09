variable "region" {
  default = "ap-south-1"
}

variable "key_name" {
  default = "Add_Key_Name"
}

variable "db_password" {
  sensitive = true
}
