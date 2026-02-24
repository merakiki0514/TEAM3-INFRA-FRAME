# ----------- [필수 입력 값] -----------
variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

# ----------- [선택적 서브넷 (비워두면 생성 안 함)] -----------
variable "public_subnet_cidrs" {
  description = "Public Subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "private_app_subnet_cidrs" {
  description = "Private App Subnet CIDRs (NAT 연결 대상)"
  type        = list(string)
  default     = []
}

variable "private_db_subnet_cidrs" {
  description = "Private DB Subnet CIDRs (인터넷 차단)"
  type        = list(string)
  default     = []
}

# ----------- [기능 On/Off 스위치] -----------
variable "enable_nat_sg" {
  description = "NAT Instance용 Security Group 생성 여부"
  type        = bool
  default     = false
}

variable "enable_nat_instance" {
  description = "NAT Instance 생성 여부 (Main VPC용)"
  type        = bool
  default     = false
}

variable "enable_ssm_endpoints" {
  description = "SSM Endpoint 생성 여부"
  type        = bool
  default     = false
}

# ----------- [NAT/SSM 관련 옵션 (기능 켤 때만 필요)] -----------
variable "nat_instance_ami" {
  type    = string
  default = "" # NAT 미사용시 불필요하므로 empty string 허용
}

variable "nat_instance_type" {
  type = string
  default = "t3.micro"
}

variable "key_pair" {
  type    = string
  default = null # Bastion 없을 수 있으므로 null 허용
}

variable "nat_sg_id" {
  description = "NAT Instance용 SG ID (enable_nat_instance=true 일 때 필수)"
  type        = string
  default     = null
}

variable "vpc_ssm_sg_id" {
  description = "SSM Endpoint용 SG ID (enable_ssm_endpoints=true 일 때 필수)"
  type        = string
  default     = null
}

variable "nat_userdata" {
  type        = string
  description = "Nat userdata"
  default = ""
}

variable "enable_vpc_ssm_sg" {
  description = "VPC SSM SG 생성 여부"
  type        = bool
  default     = false
}