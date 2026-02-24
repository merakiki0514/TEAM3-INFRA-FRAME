# 1. ALB SG
resource "aws_security_group" "alb" {
  count  = var.enable_alb_sg ? 1 : 0
  name   = "${var.project_name}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-alb-sg" }
}

# 2. App (EKS Node) SG 
resource "aws_security_group" "app" {
  count  = var.enable_app_sg ? 1 : 0
  name   = "${var.project_name}-app-sg"
  vpc_id = var.vpc_id

  # 2-1. ALB → Node 
  ingress {
    description     = "Allow from ALB"
    from_port       = 30000
    to_port         = 32767
    protocol        = "tcp"
    security_groups = var.allowed_alb_sg_ids 
  }

  # 2-2. Bastion Network → Node (SSM용 443, SSH 22 허용)
  # 이제 Bastion의 보안 그룹 ID를 달고 있는 녀석만 접속 가능합니다.
  ingress {
    description     = "HTTPS from Bastion SG (for SSM)"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.allowed_bastion_sg_ids 
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = var.allowed_bastion_sg_ids
  }

  # 2-3. [필수] Node끼리의 통신 허용 (EKS 동작 필수)
  ingress {
    description = "Allow Node to Node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-app-sg" }
}

# 3. DB SG [수정됨]
resource "aws_security_group" "db" {
  count  = var.enable_db_sg ? 1 : 0
  name   = "${var.project_name}-db-sg"
  vpc_id = var.vpc_id

  # 3-1. App → DB (기존 유지)
  ingress {
    description     = "Allow from App (EKS Nodes)"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allowed_app_sg_ids
  }

  # 3-2. [추가] Bastion → DB (관리자 접속용)
  # Bastion SG ID를 통해 접근을 허용합니다.
  ingress {
    description     = "Allow from Bastion (Admin Access)"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allowed_bastion_sg_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-db-sg" }
}

# 4. Bastion SG
resource "aws_security_group" "bastion" {
  count  = var.enable_bastion_sg ? 1 : 0
  name   = "${var.project_name}-bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 보안상 내 IP로 변경 권장
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-bastion-sg" }
}
