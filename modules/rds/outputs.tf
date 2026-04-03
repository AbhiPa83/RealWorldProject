output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.mysql_db.endpoint
}

output "db_address" {
  description = "Database address"
  value       = aws_db_instance.mysql_db.address
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.mysql_db.port
}

output "db_identifier" {
  description = "Database identifier"
  value       = aws_db_instance.mysql_db.identifier
}

output "db_resource_id" {
  description = "Database resource ID"
  value       = aws_db_instance.mysql_db.resource_id
}
