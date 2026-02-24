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

variable "cluster_version" {
  description = "Kubernetes Version"
  type        = string
  default     = "1.31" # 최신 안정 버전 권장
}

# ----------- [Node Group 설정] -----------
variable "node_instance_types" {
  description = "Worker Node EC2 Type"
  type        = list(string)
  default     = ["t3.medium"] # 비용 효율적인 타입
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 3
}
