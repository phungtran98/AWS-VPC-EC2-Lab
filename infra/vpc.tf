# VPC
resource "aws_vpc" "main-app-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-app-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "main-app-public-subnet" {
  vpc_id                  = aws_vpc.main-app-vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "main-app-public-subnet"
    Type = "Public"
  }
}

# Private Subnet
resource "aws_subnet" "main-app-private-subnet" {
  vpc_id            = aws_vpc.main-app-vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "main-app-private-subnet"
    Type = "Private"
  }
}

