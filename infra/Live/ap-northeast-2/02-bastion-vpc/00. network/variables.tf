variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project_name" {
  type    = string
  default = "team3-bastion"
}

# [중요] Main VPC(10.3.0.0/16)와 겹치지 않게 10.9.0.0/16 사용
variable "vpc_cidr" {
  type    = string
  default = "10.9.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

# Bastion용 Public Subnet 1~2개
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.9.1.0/24"]
}