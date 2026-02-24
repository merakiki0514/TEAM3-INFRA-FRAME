variable "project_name" {
  type = string
}

variable "cluster_version" {
  description = "Kubernetes Version (e.g., 1.29)"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "EKS가 배치될 Private Subnet IDs"
  type        = list(string)
}

variable "cluster_sg_ids" {
  description = "Control Plane에 적용할 추가 보안그룹 IDs"
  type        = list(string)
  default     = []
}

# ----------- [Node Group 설정] -----------
variable "node_instance_types" {
  description = "Worker Node Instance Types"
  type        = list(string)
  default     = ["t3.medium"]
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

# ----------- [접근 제어] -----------
variable "key_pair" {
  description = "Worker Node SSH Key Pair Name"
  type        = string
  default     = null
}

variable "bastion_sg_id" {
  description = "SSH 접근을 허용할 Bastion SG ID"
  type        = string
  default     = null
}