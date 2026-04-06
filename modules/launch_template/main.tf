resource "aws_launch_template" "lt" {
  name_prefix   = "app-lt"
  image_id      = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"

  key_name               = var.key_name
  vpc_security_group_ids = [var.sg_id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y

yum install -y httpd mysql
systemctl start httpd
systemctl enable httpd

echo "Connected to RDS: ${var.db_endpoint}" > /var/www/html/index.html
EOF
  )
}