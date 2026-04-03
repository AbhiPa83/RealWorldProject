# VPC
resource "aws_vpc" "proj_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "proj_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "proj_igw" {
  vpc_id = aws_vpc.proj_vpc.id
  tags = {
    Name = "proj_igw"
  }
}

# Public Subnets in 2 AZs
resource "aws_subnet" "proj_subnet_public_1a" {
  vpc_id                  = aws_vpc.proj_vpc.id
  cidr_block              = var.public_subnet_1a_cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet-AZ1"
  }
}

resource "aws_subnet" "proj_subnet_public_1b" {
  vpc_id                  = aws_vpc.proj_vpc.id
  cidr_block              = var.public_subnet_1b_cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet-AZ2"
  }
}

# Private Subnets in 2 AZs
resource "aws_subnet" "proj_subnet_private_1a" {
  vpc_id            = aws_vpc.proj_vpc.id
  cidr_block        = var.private_subnet_1a_cidr
  availability_zone = var.az_1
  tags = {
    Name = "Private-Subnet-AZ1"
  }
}

resource "aws_subnet" "proj_subnet_private_1b" {
  vpc_id            = aws_vpc.proj_vpc.id
  cidr_block        = var.private_subnet_1b_cidr
  availability_zone = var.az_2
  tags = {
    Name = "Private-Subnet-AZ2"
  }
}

# Database Subnet
resource "aws_subnet" "proj_subnet_db" {
  vpc_id            = aws_vpc.proj_vpc.id
  cidr_block        = var.db_subnet_cidr
  availability_zone = var.az_1
  tags = {
    Name = "DB-Subnet"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip_1a" {
  domain = "vpc"
  tags = {
    Name = "NAT-EIP-AZ1"
  }
  depends_on = [aws_internet_gateway.proj_igw]
}

resource "aws_eip" "nat_eip_1b" {
  domain = "vpc"
  tags = {
    Name = "NAT-EIP-AZ2"
  }
  depends_on = [aws_internet_gateway.proj_igw]
}

# NAT Gateways
resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_eip_1a.id
  subnet_id     = aws_subnet.proj_subnet_public_1a.id
  tags = {
    Name = "NAT-GW-AZ1"
  }
  depends_on = [aws_internet_gateway.proj_igw]
}

resource "aws_nat_gateway" "nat_1b" {
  allocation_id = aws_eip.nat_eip_1b.id
  subnet_id     = aws_subnet.proj_subnet_public_1b.id
  tags = {
    Name = "NAT-GW-AZ2"
  }
  depends_on = [aws_internet_gateway.proj_igw]
}

# Route Tables for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.proj_vpc.id
  tags = {
    Name = "Public-RT"
  }
}

resource "aws_route" "public_route_igw" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.proj_igw.id
}

resource "aws_route_table_association" "public_1a_assoc" {
  subnet_id      = aws_subnet.proj_subnet_public_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_1b_assoc" {
  subnet_id      = aws_subnet.proj_subnet_public_1b.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Tables for Private Subnets
resource "aws_route_table" "private_rt_1a" {
  vpc_id = aws_vpc.proj_vpc.id
  tags = {
    Name = "Private-RT-AZ1"
  }
}

resource "aws_route" "private_route_nat_1a" {
  route_table_id         = aws_route_table.private_rt_1a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1a.id
}

resource "aws_route_table_association" "private_1a_assoc" {
  subnet_id      = aws_subnet.proj_subnet_private_1a.id
  route_table_id = aws_route_table.private_rt_1a.id
}

resource "aws_route_table" "private_rt_1b" {
  vpc_id = aws_vpc.proj_vpc.id
  tags = {
    Name = "Private-RT-AZ2"
  }
}

resource "aws_route" "private_route_nat_1b" {
  route_table_id         = aws_route_table.private_rt_1b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1b.id
}

resource "aws_route_table_association" "private_1b_assoc" {
  subnet_id      = aws_subnet.proj_subnet_private_1b.id
  route_table_id = aws_route_table.private_rt_1b.id
}

# Route Table for Database Subnet
resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.proj_vpc.id
  tags = {
    Name = "DB-RT"
  }
}

resource "aws_route_table_association" "db_assoc" {
  subnet_id      = aws_subnet.proj_subnet_db.id
  route_table_id = aws_route_table.db_rt.id
}