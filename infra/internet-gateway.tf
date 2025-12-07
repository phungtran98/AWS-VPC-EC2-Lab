# Internet Gateway
resource "aws_internet_gateway" "main-app-internet-gateway" {
  vpc_id = aws_vpc.main-app-vpc.id

  tags = {
    Name = "main-app-internet-gateway"
  }
}

