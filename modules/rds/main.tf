# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "DB-Subnet-Group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql_db" {
  identifier     = var.db_identifier
  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage    = var.allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.mysql_security_group_id]

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.db_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  multi_az               = var.multi_az
  publicly_accessible    = false
  deletion_protection    = var.deletion_protection

  tags = {
    Name = "App-MySQL-DB"
  }
}

# DB Parameter Group (optional - for custom configurations)
resource "aws_db_parameter_group" "mysql_params" {
  family = "mysql${var.db_engine_version}"
  name   = "app-mysql-params"

  parameter {
    name  = "max_connections"
    value = "1000"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  tags = {
    Name = "MySQL-Param-Group"
  }
}
