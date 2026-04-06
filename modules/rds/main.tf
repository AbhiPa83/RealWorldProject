resource "aws_db_subnet_group" "db_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = var.db_subnets
}

resource "aws_db_instance" "mysql" {
  identifier         = "mydb-instance"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20

  db_name  = var.db_name
  username = var.username
  password = var.password

  vpc_security_group_ids = [var.sg_id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name

  publicly_accessible = false
  skip_final_snapshot = true
  multi_az            = false
}