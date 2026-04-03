output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.proj_vpc.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.proj_vpc.cidr_block
}

output "public_subnet_1a_id" {
  description = "Public subnet AZ1 ID"
  value       = aws_subnet.proj_subnet_public_1a.id
}

output "public_subnet_1b_id" {
  description = "Public subnet AZ2 ID"
  value       = aws_subnet.proj_subnet_public_1b.id
}

output "private_subnet_1a_id" {
  description = "Private subnet AZ1 ID"
  value       = aws_subnet.proj_subnet_private_1a.id
}

output "private_subnet_1b_id" {
  description = "Private subnet AZ2 ID"
  value       = aws_subnet.proj_subnet_private_1b.id
}

output "db_subnet_id" {
  description = "Database subnet ID"
  value       = aws_subnet.proj_subnet_db.id
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.proj_igw.id
}

output "nat_gateway_1a_id" {
  description = "NAT Gateway AZ1 ID"
  value       = aws_nat_gateway.nat_1a.id
}

output "nat_gateway_1b_id" {
  description = "NAT Gateway AZ2 ID"
  value       = aws_nat_gateway.nat_1b.id
}
