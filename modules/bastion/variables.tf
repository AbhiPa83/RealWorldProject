variable "subnet_id" {}
variable "sg_id" {}
variable "key_name" {
    description = "Pem key for the Linux servers"
    default = LinuxTest
}