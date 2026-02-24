variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  description = "ALB가 배치될 Subnet IDs (Public or Private)"
  type        = list(string)
}

variable "security_groups" {
  description = "ALB에 적용할 Security Group IDs"
  type        = list(string)
}

# ----------- [ALB 설정] -----------
variable "alb_name_suffix" {
  description = "ALB 이름 접미사 (예: public-alb, internal-alb)"
  type        = string
  default     = "alb"
}

variable "internal" {
  description = "내부 로드밸런서 여부 (true면 사설 IP만 가짐)"
  type        = bool
  default     = false
}

# ----------- [Target Group 설정] -----------
variable "target_group_port" {
  description = "타겟 그룹 포트 (NodePort)"
  type        = number
  default     = 30000
}

variable "target_group_protocol" {
  description = "타겟 그룹 프로토콜"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "헬스 체크 경로"
  type        = string
  default     = "/"
}

# ----------- [HTTPS & ASG 설정 (신규 추가)] -----------
variable "acm_certificate_arn" {
  description = "기존에 생성된 ACM 인증서 ARN (수동 생성한 것)"
  type        = string
}

variable "asg_name" {
  description = "Target Group에 연결할 Auto Scaling Group 이름 (EKS Node Group의 ASG)"
  type        = string
}