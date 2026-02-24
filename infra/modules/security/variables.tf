variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }

# ----------- [On/Off Flags] -----------
variable "enable_alb_sg" {
  description = "ALB SG 생성 여부"
  type        = bool
  default     = false
}
variable "enable_app_sg" {
  description = "App(EKS Node) SG 생성 여부"
  type        = bool
  default     = false
}
variable "enable_db_sg" {
  description = "DB SG 생성 여부"
  type        = bool
  default     = false
}
variable "enable_bastion_sg" {
  description = "Bastion SG 생성 여부"
  type        = bool
  default     = false
}

# ----------- [External Dependency Injection] -----------
# 다른 모듈이나 다른 VPC에서 만든 SG ID를 허용하기 위한 변수들

variable "allowed_bastion_sg_ids" {
  description = "SSH 허용할 Bastion SG ID 목록 (App SG에서 사용)"
  type        = list(string)
  default     = []
}

variable "allowed_alb_sg_ids" {
  description = "App 접근을 허용할 ALB SG ID 목록 (App SG에서 사용)"
  type        = list(string)
  default     = []
}

variable "allowed_app_sg_ids" {
  description = "DB 접근을 허용할 App SG ID 목록 (DB SG에서 사용)"
  type        = list(string)
  default     = []
}