# Security Group for App (Public Subnet)
resource "aws_security_group" "app" {
  name        = "main-app-security-group"
  description = "Security group for App instance in public subnet"
  vpc_id      = aws_vpc.main-app-vpc.id

  # Allow SSH from anywhere (for learning purposes)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main-app-security-group"
  }
}

# Security Group for DB (Private Subnet)
resource "aws_security_group" "db" {
  name        = "main-app-db-security-group"
  description = "Security group for DB instance in private subnet"
  vpc_id      = aws_vpc.main-app-vpc.id

  # Allow MySQL/Aurora from App security group only
  ingress {
    description     = "MySQL from App"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # Allow PostgreSQL from App security group only
  ingress {
    description     = "PostgreSQL from App"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # Allow SSH from App security group only (for management)
  ingress {
    description     = "SSH from App"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # Allow all outbound traffic (for updates, etc.)
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main-app-db-security-group"
  }
}

# Network ACL for Public Subnet
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main-app-vpc.id
  subnet_ids = [aws_subnet.main-app-public-subnet.id]

  # Allow inbound HTTP
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow inbound HTTPS
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow inbound SSH
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow inbound ephemeral ports (for return traffic)
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow all outbound
  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  tags = {
    Name = "main-app-public-nacl"
  }
}

# Network ACL for Private Subnet
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main-app-vpc.id
  subnet_ids = [aws_subnet.main-app-private-subnet.id]

  # Allow inbound from public subnet
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    from_port  = 3306
    to_port    = 3306
    cidr_block = var.public_subnet_cidr
    action     = "allow"
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    from_port  = 5432
    to_port    = 5432
    cidr_block = var.public_subnet_cidr
    action     = "allow"
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_block = var.public_subnet_cidr
    action     = "allow"
  }

  # Allow inbound ephemeral ports
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = var.vpc_cidr
    action     = "allow"
  }

  # Allow all outbound
  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  tags = {
    Name = "main-app-private-nacl"
  }
}

# EC2 Instance for App (Public Subnet)
resource "aws_instance" "my-app-instance" {
  ami                    = var.app_ami != "" ? var.app_ami : data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name != "" ? var.key_name : null
  subnet_id              = aws_subnet.main-app-public-subnet.id
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd mod_ssl
              
              # Create HTML content
              echo "<h1>App Server in Public Subnet</h1><p>VPC: ${aws_vpc.main-app-vpc.id}</p><p>Subnet: ${aws_subnet.main-app-public-subnet.id}</p>" > /var/www/html/index.html
              
              # Configure Apache to listen on port 443 with self-signed certificate
              # Generate self-signed certificate
              openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout /etc/pki/tls/private/apache-selfsigned.key \
                -out /etc/pki/tls/certs/apache-selfsigned.crt \
                -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
              
              # Create SSL configuration
              cat > /etc/httpd/conf.d/ssl.conf <<'SSL_EOF'
              Listen 443 https
              <VirtualHost *:443>
                  ServerName localhost
                  DocumentRoot /var/www/html
                  SSLEngine on
                  SSLCertificateFile /etc/pki/tls/certs/apache-selfsigned.crt
                  SSLCertificateKeyFile /etc/pki/tls/private/apache-selfsigned.key
              </VirtualHost>
              SSL_EOF
              
              # Start and enable Apache
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "main-app-instance"
    Type = "App"
  }
}

# Key Pair for Private DB Instance
resource "tls_private_key" "private_db_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "private_db_keypair" {
  key_name   = "my-private-db-instance-keypair"
  public_key = tls_private_key.private_db_key.public_key_openssh

  tags = {
    Name = "my-private-db-instance-keypair"
  }
}

# Save private key to local file
resource "local_file" "private_db_key_file" {
  content         = tls_private_key.private_db_key.private_key_pem
  filename        = "${path.module}/../my-private-db-instance-key.pem"
  file_permission = "0400"
}

# EC2 Instance for Private Subnet (Cost-optimized)
resource "aws_instance" "my-private-db-instance" {
  ami                    = var.db_ami != "" ? var.db_ami : data.aws_ami.amazon_linux.id
  instance_type          = var.db_instance_type
  key_name               = aws_key_pair.private_db_keypair.key_name
  subnet_id              = aws_subnet.main-app-private-subnet.id
  vpc_security_group_ids = [aws_security_group.db.id]

  # Disable detailed monitoring to save costs
  monitoring = false

  # Use standard CPU credits (cheaper than unlimited)
  credit_specification {
    cpu_credits = "standard"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              EOF

  tags = {
    Name = "my-private-db-instance"
    Type = "Private"
  }
}

