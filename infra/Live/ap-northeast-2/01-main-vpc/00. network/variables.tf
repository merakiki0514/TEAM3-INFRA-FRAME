variable "aws_region" {
  description = "리전 설정"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트 이름 (모든 리소스 이름의 접두사)"
  type        = string
  # ###### [TODO] 프로젝트 이름을 변경하세요 ######
  default     = "team3-main"
}

variable "vpc_cidr" {
  description = "Main VPC의 CIDR 대역"
  type        = string
  # ###### [TODO] 아키텍처 설계에 맞는 CIDR을 확인하세요 ######
  default     = "10.3.0.0/16"
}

variable "azs" {
  description = "사용할 가용 영역 목록"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

# ----------- [서브넷 설정] -----------
variable "public_subnet_cidrs" {
  description = "Public Subnet 2개 (ALB, Bastion, NAT용)"
  type        = list(string)
  default     = ["10.3.1.0/24", "10.3.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Private App Subnet 2개 (EKS Node용)"
  type        = list(string)
  default     = ["10.3.11.0/24", "10.3.12.0/24"]
}

# ----------- [NAT 및 접속 설정] -----------
variable "key_pair" {
  description = "EC2 접속용 Key Pair 이름 (콘솔에서 미리 생성 필요)"
  type        = string
  # ###### [TODO] AWS 콘솔에 있는 실제 키 페어 이름을 정확히 입력하세요 ######
  default     = "Team3_project_seoul"
}

variable "nat_instance_ami" {
  description = "NAT 인스턴스용 AMI ID"
  type        = string
  default     = "ami-013c951bfeb5d9c3b"
}