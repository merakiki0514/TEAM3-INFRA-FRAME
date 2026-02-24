variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project_name" {
  type    = string
  default = "team3-db"
}

# [중요] Main(10.3.0.0/16), Bastion(10.9.0.0/16)과 겹치지 않는 10.6.0.0/16 대역 사용
variable "vpc_cidr" {
  type    = string
  default = "10.6.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

# DB용 Private Subnet 2개
variable "private_db_subnet_cidrs" {
  type    = list(string)
  default = ["10.6.1.0/24", "10.6.2.0/24"]
}