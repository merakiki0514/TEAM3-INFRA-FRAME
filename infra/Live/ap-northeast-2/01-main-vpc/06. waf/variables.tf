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

variable "scope" {
  description = "WAF Scope (ALB용은 REGIONAL, CloudFront용은 CLOUDFRONT)"
  type        = string
  default     = "REGIONAL"
}