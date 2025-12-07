variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile name"
  type        = string
  default     = "ttphun"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance type for App instance"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_type" {
  description = "EC2 instance type for DB instance (optimized for cost-effective testing)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for EC2 instances"
  type        = string
  default     = ""
}

variable "app_ami" {
  description = "AMI ID for App instance"
  type        = string
  default     = "" # Will use data source to get latest Amazon Linux 2 AMI
}

variable "db_ami" {
  description = "AMI ID for DB instance"
  type        = string
  default     = "" # Will use data source to get latest Amazon Linux 2 AMI
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "AWS-VPC-EC2-Lab"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}

