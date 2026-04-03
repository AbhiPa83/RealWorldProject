# Launch Template for EC2 Instances
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.ec2_security_group_id]
    delete_on_termination       = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_endpoint = var.db_endpoint
    db_user     = var.db_user
    db_password = var.db_password
    db_name     = var.db_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "App-Server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Host EC2 Instance
resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.bastion_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_security_group_id]
  key_name               = var.key_pair_name

  associate_public_ip_address = true

  tags = {
    Name = "Bastion-Host"
  }
}
