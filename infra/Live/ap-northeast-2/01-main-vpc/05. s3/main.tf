# -----------------------------------------------------------------------
# 현재 AWS 계정 ID 조회
# -----------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------
# KMS Key 조회
# -----------------------------------------------------------------------
data "aws_kms_key" "s3_key" {
  key_id = "alias/team3-project-secure-data"
}

# =======================================================================
# 1. General Log Archive Bucket (EKS, VPC Flow Logs 등)
# =======================================================================
module "s3_logs" {
  source = "../../../../modules/s3"

  project_name = var.project_name
  
  # [이름] team3-main-log-archive-{AccountID}-{Region}
  bucket_name  = "${var.project_name}-${var.bucket_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  enable_versioning  = true
  force_destroy      = true
  enable_object_lock = true 
  kms_key_arn        = data.aws_kms_key.s3_key.arn
  block_public_access = true
}

# =======================================================================
# 2. WAF Log Bucket
# AWS WAF의 S3 직접 로깅(Direct Logging)을 지원하려면
# 버킷 이름이 반드시 'aws-waf-logs-'로 시작해야 합니다.
# =======================================================================
module "waf_logs" {
  source = "../../../../modules/s3"

  project_name = var.project_name

  # [필수 규칙] aws-waf-logs- 접두사 사용
  bucket_name  = "aws-waf-logs-${var.project_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  # WAF 로그는 양이 많으므로 버전 관리보다는 수명 주기 관리가 중요 (모듈 지원 시 설정)
  enable_versioning = true 
  force_destroy     = true
  enable_object_lock = true 
  block_public_access = true
  # WAF 로그도 암호화하여 저장
  kms_key_arn       = data.aws_kms_key.s3_key.arn
}