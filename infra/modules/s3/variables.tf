variable "bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
}

variable "project_name" {
  description = "Project name for tags"
  type        = string
}

variable "force_destroy" {
  description = "Delete all objects when destroying the bucket"
  type        = bool
  default     = false
}

# ----------- [보안 및 규정 준수 옵션] -----------
variable "enable_versioning" {
  description = "Enable Versioning (Replication을 위해 필수)"
  type        = bool
  default     = true
}

variable "enable_object_lock" {
  description = "Enable Object Lock (생성 시에만 설정 가능)"
  type        = bool
  default     = false # 일반 버킷은 false, 로그용은 true 권장
}

variable "object_lock_mode" {
  description = "Object Lock Mode (GOVERNANCE or COMPLIANCE)"
  type        = string
  default     = "GOVERNANCE"
}

variable "object_lock_days" {
  description = "Object Lock Retention Days"
  type        = number
  default     = 0 # 0이면 설정 안 함
}

variable "block_public_access" {
  description = "for public access control"
  type = bool
  default = true
}

# ----------- [암호화 옵션] -----------
variable "kms_key_arn" {
  description = "KMS Key ARN (null이면 S3 Managed Key(AES256) 사용)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable Bucket Key to reduce KMS costs"
  type        = bool
  default     = true
}

# ----------- [수명 주기 (Lifecycle)] -----------
variable "enable_lifecycle" {
  description = "수명 주기 규칙 활성화 여부"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id              = string
    status          = string
    transition_days = optional(number)
    storage_class   = optional(string)
    expiration_days = optional(number)
  }))
  default = []
}
# ------------ replica용 rule 생성---------------------------
variable "create_replication_role" {
  description = "Replication용 IAM Role 생성 여부"
  type        = bool
  default     = true
}

variable "replication_role_name" {
  description = "생성할 IAM Role의 이름"
  type        = string
  default     = "s3-replication-role"
}

variable "destination_bucket_arn" {
  description = "복제 대상(Destination) S3 버킷의 ARN (Role 생성 시 필수)"
  type        = string
  default     = "arn:aws:s3:::backup-team3-main-log-archive-404234477930-ap-northeast-2"
}

variable "destination_kms_key_arn" {
  description = "복제 대상(Destination) 버킷 암호화에 사용할 KMS Key ARN (KMS 사용 시 필수)"
  type        = string
  default     = "arn:aws:kms:us-east-1:404234477930:key/222e27cf-feb0-4f52-982a-2835bf62079f"
}