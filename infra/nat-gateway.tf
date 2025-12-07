# Elastic IP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"

  tags = {
    Name = "main-app-nat-gateway-eip"
  }

  depends_on = [aws_internet_gateway.main-app-internet-gateway]
}

# NAT Gateway
resource "aws_nat_gateway" "main-app-nat-gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.main-app-public-subnet.id

  tags = {
    Name = "main-app-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main-app-internet-gateway]
}

