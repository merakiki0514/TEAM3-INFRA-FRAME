# 1. VPC & IGW (기본 생성)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  # Public Subnet이 하나라도 있을 때만 생성하거나, 그냥 둬도 무방함 (여기선 항상 생성)
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.project_name}-igw" }
}

# 2. Subnets (리스트 길이만큼 동적 생성)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
    Tier = "public"
  }
}

resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.project_name}-private-app-${count.index + 1}"
    Tier = "app"
  }
}

resource "aws_subnet" "private_db" {
  count             = length(var.private_db_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.project_name}-private-db-${count.index + 1}"
    Tier = "db"
  }
}

# 3. Route Tables
# Public RT
resource "aws_route_table" "public_rt" {
  count  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt[0].id
}

# Private App RT (NAT 연결은 아래에서 조건부 처리)
resource "aws_route_table" "private_app_rt" {
  count  = length(var.private_app_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-private-app-rt" }
}

resource "aws_route_table_association" "private_app_assoc" {
  count          = length(var.private_app_subnet_cidrs)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app_rt[0].id
}

# Private DB RT (Isolated)
resource "aws_route_table" "private_db_rt" {
  count  = length(var.private_db_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-private-db-rt" }
}

resource "aws_route_table_association" "private_db_assoc" {
  count          = length(var.private_db_subnet_cidrs)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db_rt[0].id
}

# NAT SG 선행 생성
resource "aws_security_group" "nat" {
  count  = var.enable_nat_sg ? 1 : 0  # True일 때만 생성
  name   = "${var.project_name}-nat-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Private subnet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-nat-sg" }
}

# 4. NAT Instance (Optional)
resource "aws_instance" "nat" {
  count                       = var.enable_nat_instance ? 1 : 0
  ami                         = var.nat_instance_ami
  instance_type               = var.nat_instance_type
  subnet_id                   = aws_subnet.public[0].id # 첫 번째 Public Subnet에 배치
  associate_public_ip_address = true
  source_dest_check           = false
  vpc_security_group_ids      = [aws_security_group.nat[0].id]
  key_name                    = var.key_pair
  user_data                   = var.nat_userdata
  
  tags = { Name = "${var.project_name}-nat-instance" }
}

# NAT Route (NAT Instance가 켜져 있을 때만 라우트 생성)
resource "aws_route" "private_nat_route" {
  count                  = var.enable_nat_instance ? 1 : 0
  route_table_id         = aws_route_table.private_app_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat[0].primary_network_interface_id
}

# -----------------------------------------------------------------------
# [추가] VPC Endpoint용 Security Group (모듈 내부 생성)
# -----------------------------------------------------------------------
resource "aws_security_group" "vpc_ssm" {
  count       = var.enable_ssm_endpoints ? 1 : 0
  name        = "${var.project_name}-vpc-ssm-sg"
  description = "Allow HTTPS for VPC Endpoints"
  vpc_id      = aws_vpc.main.id # 모듈 내부 VPC 참조

  # VPC 내부에서 오는 HTTPS(443) 허용
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-vpc-ssm-sg" }
}

# 5. SSM Endpoints (Optional)
resource "aws_vpc_endpoint" "ssm" {
  count               = var.enable_ssm_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id # App Subnet에 배치
  security_group_ids  = [aws_security_group.vpc_ssm[0].id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count               = var.enable_ssm_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_ssm[0].id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  count               = var.enable_ssm_endpoints ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_ssm[0].id]
  private_dns_enabled = true
}