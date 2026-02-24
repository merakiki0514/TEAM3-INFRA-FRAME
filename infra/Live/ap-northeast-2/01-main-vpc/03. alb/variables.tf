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

variable "target_group_port" {
  description = "EKS 서비스가 열어둔 NodePort 번호 (Kubernetes Service 설정과 일치해야 함)"
  type        = number
  # ###### K8s Service(Ingress Controller)의 NodePort와 일치 ######
  default     = 30000
}

variable "health_check_path" {
  description = "헬스 체크 경로"
  type        = string
  # ###### 앱의 헬스 체크 엔드포인트에 맞춰 수정 ######
  default     = "/" 
}

# [추가] 인증서를 찾기 위한 도메인 이름
variable "domain_name" {
  description = "ACM 인증서를 찾을 도메인 이름 (예: *.myproject.com)"
  type        = string
  default = "*.team3project.click"
}