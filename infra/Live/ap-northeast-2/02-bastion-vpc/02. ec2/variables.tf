variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project_name" {
  type    = string
  default = "team3-bastion"
}

variable "key_pair" {
  type    = string
  # ###### Main VPC와 동일한 키 페어 사용 ######
  default = "Team3_project_seoul"
}

variable "bastion_ami" {
  description = "Ubuntu 24.04 LTS (ap-northeast-2)"
  type        = string
  default     = "ami-0a71e3eb8b23101ed" 
}