variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

# [핵심 변경] 리스트로 받아서 반복 생성 지원
variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = []
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image scan on push"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for ECR encryption (null uses AES256)"
  type        = string
  default     = null
}

variable "force_delete" {
  description = "If true, deleting the repo will also delete images"
  type        = bool
  default     = false
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy to expire old images"
  type        = bool
  default     = true
}

variable "image_count_retention" {
  description = "How many images to keep (when lifecycle policy enabled)"
  type        = number
  default     = 20
  validation {
    condition     = var.image_count_retention >= 1
    error_message = "image_count_retention must be >= 1."
  }
}

variable "tags" {
  description = "Tags applied to ECR resources"
  type        = map(string)
  default     = {}
}