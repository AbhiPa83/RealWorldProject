resource "aws_eip" "eip" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.public_subnet_id
}