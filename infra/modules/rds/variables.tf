variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "vpc_id" {
  type = string
}

variable "private_db_subnet_ids" {
  type        = list(string)
  description = "List of Private DB Subnet IDs"
}

variable "db_sg_id" {
  type        = string
  description = "Security Group ID for RDS"
}

# ----------- [DB 설정 변수] -----------
variable "db_identifier" {
  type        = string
  description = "Instance identifier (e.g., team3-project-db)"
  default     = null # null이면 project_name 기반으로 자동 생성
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
}

variable "db_password_ssm_name" {
  type        = string
  description = "SSM Parameter name for DB Password (Must exist in the target region)"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro" # 기본값 설정 (필요시 오버라이드 가능)
}

variable "multi_az" {
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
}