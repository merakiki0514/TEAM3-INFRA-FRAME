# [추가] IAM Role 이름 충돌 방지를 위한 랜덤 접미사 생성
resource "random_id" "role_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  # Object Lock은 버킷 생성 시에만 켤 수 있음 
  object_lock_enabled = var.enable_object_lock

  # [중요] 콘솔에서 Replication 설정을 직접 하므로 Terraform이 간섭하지 않도록 무시 설정
  lifecycle {
    ignore_changes = [
      replication_configuration
    ]
  }

  tags = {
    Name    = var.bucket_name
    Project = var.project_name
  }
}

# 1. 버저닝 설정
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# 2. 암호화 설정 (KMS or AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      # KMS ARN이 있으면 KMS 사용, 없으면 기본 AES256 사용 [cite: 63]
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null ? var.bucket_key_enabled : null
  }
}

# 3. 퍼블릭 액세스 차단 (보안 필수) [cite: 62]
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# 4. Object Lock 설정 (Optional)
resource "aws_s3_bucket_object_lock_configuration" "this" {
  # Object Lock이 켜져 있고, 유지 기간(days)이 0보다 클 때만 생성 [cite: 63]
  count  = var.enable_object_lock && var.object_lock_days > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode = var.object_lock_mode
      days = var.object_lock_days
    }
  }
}

# 5. 수명 주기 설정 (Optional)
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.enable_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status
      
      filter {} # 전체 적용

      # Transition (스토리지 계층 이동)
      dynamic "transition" {
        for_each = rule.value.transition_days != null ? [1] : []
        content {
          days          = rule.value.transition_days
          storage_class = rule.value.storage_class
        }
      }

      # Expiration (삭제)
      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }
    }
  }
}

# -------------------------------------------------------------------------
# Replication IAM Role & Policy (Optional)
# -------------------------------------------------------------------------

# 1. IAM Role 생성 (Trust Policy)
resource "aws_iam_role" "replication" {
  count = var.create_replication_role ? 1 : 0

  # [수정] 프로젝트명과 랜덤 ID를 붙여 유일한 이름 생성
  name = "${var.project_name}-${var.replication_role_name}-${random_id.role_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# 2. IAM Policy Document 정의 (동적 생성)
data "aws_iam_policy_document" "replication" {
  count = var.create_replication_role ? 1 : 0

  # (1) Source Bucket 권한 (Get, List)
  statement {
    sid    = "SourceBucketPermissions"
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.this.arn
    ]
  }

  # (2) Source Object 권한 (Get Version)
  statement {
    sid    = "SourceBucketObjectPermissions"
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }

  # (3) Destination Bucket 권한 (Replicate)
  statement {
    sid    = "DestinationBucketPermissions"
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]
    resources = [
      "${var.destination_bucket_arn}/*"
    ]
  }

  # (4) Source KMS Key Decrypt (원본 키가 있을 경우만 추가)
  dynamic "statement" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      sid    = "SourceKeyDecryptPermission"
      effect = "Allow"
      actions = [
        "kms:Decrypt"
      ]
      resources = [var.kms_key_arn]
      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values   = ["s3.*.amazonaws.com"]
      }
      condition {
        test     = "StringLike"
        variable = "kms:EncryptionContext:aws:s3:arn"
        values   = ["${aws_s3_bucket.this.arn}/*"]
      }
    }
  }

  # (5) Destination KMS Key Encrypt (대상 키가 있을 경우만 추가)
  dynamic "statement" {
    for_each = var.destination_kms_key_arn != "" ? [1] : []
    content {
      sid    = "DestinationKeyEncryptPermission"
      effect = "Allow"
      actions = [
        "kms:Encrypt"
      ]
      resources = [var.destination_kms_key_arn]
      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values   = ["s3.*.amazonaws.com"]
      }
      condition {
        test     = "StringLike"
        variable = "kms:EncryptionContext:aws:s3:arn"
        values   = ["${var.destination_bucket_arn}/*"]
      }
    }
  }
}

# 3. Policy 생성 및 Role 연결
resource "aws_iam_policy" "replication" {
  count = var.create_replication_role ? 1 : 0

  name   = "${var.project_name}-${var.replication_role_name}-policy-${random_id.role_suffix.hex}"
  policy = data.aws_iam_policy_document.replication[0].json
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = var.create_replication_role ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}