variable "aws_region" {
  type    = string
  default = "us-east-1" # [변경] 버지니아 리전
}

variable "project_name" {
  type    = string
  default = "team3-backup" # [변경] 프로젝트 이름 식별
}

# [중요] 서울(10.0.0.0/8)과 겹치지 않는 대역
variable "vpc_cidr" {
  type    = string
  default = "20.6.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1c"] # [변경] 버지니아 AZ
}

# Public Subnet 불필요 (로드밸런서/Bastion 없음)
variable "public_subnet_cidrs" {
  type    = list(string)
  default = []
}

# DB용 Private Subnet만 존재 (RDS Replica용)
variable "private_db_subnet_cidrs" {
  # 변수명은 app_subnet이지만, 실제론 DB용으로 쓰시는 CIDR을 넣으시면 됩니다.
  # 혹은 모듈 구조에 따라 private_db_subnet_cidrs 쪽에 넣으셔도 됩니다.
  type    = list(string)
  default = ["20.6.1.0/24", "20.6.2.0/24"] 
}