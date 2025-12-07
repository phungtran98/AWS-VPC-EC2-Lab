# Route Table for Public Subnet
resource "aws_route_table" "main-app-public-route-table" {
  vpc_id = aws_vpc.main-app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-app-internet-gateway.id
  }

  tags = {
    Name = "main-app-public-route-table"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "main-app-public-route-table-association" {
  subnet_id      = aws_subnet.main-app-public-subnet.id
  route_table_id = aws_route_table.main-app-public-route-table.id
}

# Route Table for Private Subnet
resource "aws_route_table" "main-app-private-route-table" {
  vpc_id = aws_vpc.main-app-vpc.id

  # No route to internet gateway - this keeps it private
  # Only local VPC traffic is allowed

  tags = {
    Name = "main-app-private-route-table"
  }
}

# Route Table Association for Private Subnet
resource "aws_route_table_association" "main-app-private-route-table-association" {
  subnet_id      = aws_subnet.main-app-private-subnet.id
  route_table_id = aws_route_table.main-app-private-route-table.id
}

