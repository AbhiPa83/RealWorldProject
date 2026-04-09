resource "aws_instance" "bastion" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  key_name               = var.key_name
}