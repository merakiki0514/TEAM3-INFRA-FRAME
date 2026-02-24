variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project_name" {
  type    = string
  default = "team3-db"
}

variable "db_password_ssm_name" {
  description = "RDS 비밀번호가 저장된 SSM Parameter 이름"
  type        = string
  # 콘솔의 System Manager > Parameter Store에 이름 생성 ######
  default     = "/team3_project/rds/mysql/master_password"
}