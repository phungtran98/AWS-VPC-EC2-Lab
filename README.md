# AWS VPC & EC2 Lab với Terraform

Dự án này triển khai một kiến trúc VPC hoàn chỉnh trên AWS sử dụng Terraform, bao gồm:

- **VPC** với CIDR 10.0.0.0/16
- **Public Subnet** (10.0.1.0/24) với EC2 instance cho ứng dụng
- **Private Subnet** (10.0.2.0/24) với EC2 instance cho database
- **Internet Gateway** để kết nối public subnet với internet
- **Route Tables** cho public và private subnet
- **Security Groups** và **Network ACLs** cho bảo mật

## Kiến trúc

```
Region (us-east-1)
└── VPC (10.0.0.0/16)
    ├── Public Subnet (10.0.1.0/24)
    │   ├── App EC2 Instance
    │   ├── Security Group (App)
    │   ├── Network ACL (Public)
    │   └── Route Table (Public) → Internet Gateway
    │
    └── Private Subnet (10.0.2.0/24)
        ├── DB EC2 Instance
        ├── Security Group (DB)
        ├── Network ACL (Private)
        └── Route Table (Private) → No Internet Access
```

## Yêu cầu

- Terraform >= 1.0
- AWS CLI đã được cấu hình với credentials
- AWS Account với quyền tạo VPC, EC2, IGW, etc.

## Cài đặt

1. **Clone repository và di chuyển vào thư mục infra:**

```bash
cd infra
```

2. **Khởi tạo Terraform:**

```bash
terraform init
```

3. **Xem kế hoạch triển khai:**

```bash
terraform plan
```

4. **Triển khai infrastructure:**

```bash
terraform apply
```

Nhập `yes` khi được hỏi xác nhận.

5. **Xem outputs:**

```bash
terraform output
```

## Cấu hình

Các biến có thể tùy chỉnh trong file `variables.tf`:

- `aws_region`: AWS region (mặc định: us-east-1)
- `vpc_cidr`: CIDR block cho VPC (mặc định: 10.0.0.0/16)
- `public_subnet_cidr`: CIDR cho public subnet (mặc định: 10.0.1.0/24)
- `private_subnet_cidr`: CIDR cho private subnet (mặc định: 10.0.2.0/24)
- `instance_type`: Loại EC2 instance cho App (mặc định: t2.micro)
- `db_instance_type`: Loại EC2 instance cho DB - **tối ưu cho testing** (mặc định: t2.micro)
- `key_name`: Tên AWS Key Pair (tùy chọn)

Bạn có thể override các biến khi chạy `terraform apply`:

```bash
terraform apply -var="key_name=my-key-pair" -var="instance_type=t3.small" -var="db_instance_type=t2.micro"
```

Hoặc tạo file `terraform.tfvars`:

```hcl
aws_region = "us-east-1"
instance_type = "t2.micro"      # App instance
db_instance_type = "t2.micro"   # DB instance (tối ưu chi phí cho testing)
key_name = "my-key-pair"
```

## Các thành phần chính

### 1. VPC (vpc.tf)
- Tạo VPC với DNS hostnames và DNS support enabled
- Tạo public subnet với `map_public_ip_on_launch = true`
- Tạo private subnet không có public IP

### 2. Internet Gateway (internet-gateway.tf)
- Tạo và gắn Internet Gateway vào VPC
- Cho phép public subnet kết nối với internet

### 3. Route Tables (route-table.tf)
- **Public Route Table**: Route 0.0.0.0/0 → Internet Gateway
- **Private Route Table**: Chỉ route nội bộ VPC (không có route ra internet)

### 4. Security Groups (ec2.tf)
- **App Security Group**: 
  - Cho phép SSH (22), HTTP (80), HTTPS (443) từ internet
  - Cho phép tất cả outbound traffic
- **DB Security Group**:
  - Chỉ cho phép MySQL (3306), PostgreSQL (5432), SSH (22) từ App Security Group
  - Cho phép tất cả outbound traffic

### 5. Network ACLs (ec2.tf)
- **Public NACL**: Cho phép HTTP, HTTPS, SSH và ephemeral ports
- **Private NACL**: Chỉ cho phép traffic từ public subnet

### 6. EC2 Instances (ec2.tf)
- **App Instance**: 
  - Trong public subnet, tự động cài đặt Apache web server
  - Có public IP để truy cập từ internet
- **DB Instance**: 
  - Trong private subnet, không có public IP
  - **Tối ưu chi phí cho testing**:
    - Instance type riêng biệt (có thể cấu hình nhỏ hơn App instance)
    - Tắt Detailed Monitoring (tiết kiệm ~$2/tháng)
    - CPU Credits ở chế độ Standard (không unlimited để tránh phí phát sinh)

## Truy cập

Sau khi triển khai, bạn có thể:

1. **Truy cập App server qua SSH:**
```bash
ssh -i your-key.pem ec2-user@<app_public_ip>
```

2. **Truy cập web server:**
Mở trình duyệt và truy cập: `http://<app_public_ip>`

3. **Truy cập DB server từ App server:**
```bash
# SSH vào App server trước
ssh -i your-key.pem ec2-user@<app_public_ip>

# Sau đó SSH vào DB server từ App server
ssh ec2-user@<db_private_ip>
```

## Xóa resources

Để xóa tất cả resources đã tạo:

```bash
terraform destroy
```

Nhập `yes` khi được hỏi xác nhận.

## Tối ưu chi phí

Dự án này đã được tối ưu cho testing/learning với các tính năng sau:

### DB Instance (Cost-Optimized)
- **Instance type riêng**: Có thể cấu hình `db_instance_type` nhỏ hơn App instance
- **Tắt Detailed Monitoring**: Tiết kiệm ~$2/tháng mỗi instance (vẫn có basic monitoring)
- **CPU Credits Standard**: Sử dụng standard mode thay vì unlimited để tránh phí phát sinh
- **Mặc định t2.micro**: Instance type rẻ nhất, phù hợp cho testing

### Ước tính chi phí (us-east-1)
- **t2.micro**: ~$8.50/tháng mỗi instance (với tối ưu trên)
- **Tổng 2 instances**: ~$17/tháng
- **Lưu ý**: Chi phí có thể thay đổi theo region và thời gian sử dụng

### Tips tiết kiệm thêm
- Sử dụng `terraform destroy` khi không cần dùng
- Chọn region có giá rẻ hơn (ví dụ: us-east-1 thường rẻ nhất)
- Tắt instances khi không dùng (nhưng sẽ mất dữ liệu trên instance store)

## Lưu ý

- **Chi phí**: EC2 instances sẽ tính phí khi chạy. Nhớ `terraform destroy` khi không dùng.
- **Key Pair**: Nếu không cung cấp `key_name`, bạn sẽ không thể SSH vào instances.
- **Security**: Trong production, nên hạn chế SSH access từ 0.0.0.0/0, chỉ cho phép từ IP cụ thể.
- **Testing**: DB instance đã được tối ưu cho testing với monitoring tắt và CPU credits standard.

## Tài liệu tham khảo

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [AWS Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)

