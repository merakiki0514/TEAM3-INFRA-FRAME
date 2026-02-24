locals {
  # 리스트를 set으로 변환 (for_each는 set이나 map만 받음)
  repo_set = toset(var.repository_names)
}

resource "aws_ecr_repository" "this" {
  for_each = local.repo_set # 반복 생성

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.kms_key_arn == null ? "AES256" : "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = merge(
    var.tags,
    {
      Name    = each.value
      Project = var.project_name
    }
  )
}

# 수명 주기 정책도 리포지토리마다 각각 적용
resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.enable_lifecycle_policy ? local.repo_set : toset([])

  repository = aws_ecr_repository.this[each.value].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire images beyond retention count"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.image_count_retention
        }
        action = { type = "expire" }
      }
    ]
  })
}