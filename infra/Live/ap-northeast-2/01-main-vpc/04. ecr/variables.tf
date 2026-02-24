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

# ----------- [리포지토리 목록] -----------
variable "repository_names" {
  description = "생성할 ECR 리포지토리 이름 목록"
  type        = list(string)
  # ###### 실제 필요한 이미지 이름 ######
  default     = [
    "team3-app"
  ]
}