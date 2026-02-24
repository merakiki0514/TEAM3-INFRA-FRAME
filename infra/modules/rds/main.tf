# 해당 리전(Region)에 있는 SSM 파라미터를 조회합니다.
data "aws_ssm_parameter" "db_password" {
  name            = var.db_password_ssm_name
  with_decryption = true
}

resource "aws_db_subnet_group" "rds_group" {
  # 이름이 겹치지 않게 project_name 활용
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  # 식별자가 입력되지 않으면 project_name을 사용하여 자동 생성
  identifier = var.db_identifier != null ? var.db_identifier : "${var.project_name}-db"
  
  engine         = "mysql"
  engine_version = "8.0" # 버전을 명시하는 것이 운영상 좋습니다.
  instance_class = var.instance_class
  
  allocated_storage     = 20
  max_allocated_storage = 100 # 오토 스케일링 설정 (선택 사항)
  storage_type          = "gp3" # 최신 유형 권장

  db_name  = var.db_name
  username = var.db_username
  password = data.aws_ssm_parameter.db_password.value

  db_subnet_group_name   = aws_db_subnet_group.rds_group.name
  vpc_security_group_ids = [var.db_sg_id]

  multi_az            = var.multi_az
  skip_final_snapshot = var.skip_final_snapshot
  publicly_accessible = false
  # [추가] Terraform이 실수로 삭제하지 못하게 막음
  deletion_protection = true

  # [필수] IAM 인증 기능 활성화
  iam_database_authentication_enabled = true

  # [중요] Replica를 콘솔에서 수동으로 생성할 계획이므로, 
  # Terraform이 관리하지 않는 속성들이 변경되어도 무시하도록 설정
  lifecycle {
    ignore_changes = [
      password, # 비밀번호가 외부에서 바뀌어도 TF가 원복하지 않음
    ]
  }

  tags = {
    Name = "${var.project_name}-rds"
  }
}