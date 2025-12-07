output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main-app-vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main-app-vpc.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.main-app-public-subnet.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.main-app-private-subnet.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main-app-internet-gateway.id
}

output "app_instance_id" {
  description = "ID of the App EC2 instance"
  value       = aws_instance.my-app-instance.id
}

output "app_instance_public_ip" {
  description = "Public IP of the App EC2 instance"
  value       = aws_instance.my-app-instance.public_ip
}

output "app_instance_public_dns" {
  description = "Public DNS of the App EC2 instance"
  value       = aws_instance.my-app-instance.public_dns
}

output "private_instance_id" {
  description = "ID of the Private EC2 instance"
  value       = aws_instance.my-private-db-instance.id
}

output "private_instance_private_ip" {
  description = "Private IP of the Private EC2 instance"
  value       = aws_instance.my-private-db-instance.private_ip
}

output "app_security_group_id" {
  description = "ID of the App security group"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the DB security group"
  value       = aws_security_group.db.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.main-app-public-route-table.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.main-app-private-route-table.id
}

output "private_db_keypair_name" {
  description = "Name of the key pair for private DB instance"
  value       = aws_key_pair.private_db_keypair.key_name
}

output "private_db_key_file_path" {
  description = "Path to the private key file for private DB instance"
  value       = local_file.private_db_key_file.filename
  sensitive   = true
}

