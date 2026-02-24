variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "scope" {
  description = "WAF Scope (CLOUDFRONT or REGIONAL)"
  type        = string
  default     = "REGIONAL" # ALB용은 REGIONAL이 기본값 [cite: 51]
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with WAF (Optional)"
  type        = string
  default     = null # ALB 없이 WAF만 만들 수도 있음
}

# ----------- [확장 가능한 Rule 설정] -----------
variable "managed_rules" {
  description = "List of AWS Managed Rules to enable"
  type = list(object({
    name     = string
    priority = number
    vendor   = string
  }))
  # 기본값으로 CommonRuleSet만 포함 (사용자 코드 반영) 
  default = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 10
      vendor   = "AWS"
    }
  ]
}

variable "log_destination_arns" {
  description = "WAF 로그를 저장할 S3 Bucket ARN 목록 (aws-waf-logs- 접두사 필수)"
  type        = list(string)
  default     = []
}