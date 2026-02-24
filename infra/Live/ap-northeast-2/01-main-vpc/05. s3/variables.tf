variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "team3-main"
}

variable "bucket_prefix" {
  description = "버킷 이름 접두사 (뒤에 계정ID가 붙음)"
  type        = string
  default     = "log-archive"
}