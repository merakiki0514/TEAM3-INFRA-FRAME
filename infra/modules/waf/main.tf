resource "aws_wafv2_web_acl" "this" {
  name  = "${var.project_name}-web-acl"
  scope = var.scope
  
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf-main"
    sampled_requests_enabled   = true
  }

  # 입력받은 리스트만큼 규칙을 동적으로 생성 (확장성)
  dynamic "rule" {
    for_each = var.managed_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.project_name}-waf-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  tags = {
    Name = "${var.project_name}-web-acl"
  }
}

# ALB 연결 (alb_arn이 입력되었을 때만 수행)
resource "aws_wafv2_web_acl_association" "alb" {
  # alb_arn이 null이 아니면 1개 생성, null이면 0개(생성 안 함)
  count        = var.alb_arn != null ? 1 : 0
  
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  # 로그 저장할 버킷이 지정된 경우에만 생성
  count = length(var.log_destination_arns) > 0 ? 1 : 0

  log_destination_configs = var.log_destination_arns
  resource_arn            = aws_wafv2_web_acl.main.arn

  # 로그 필터링 (선택사항 - 필요 시 추가)
  logging_filter {
    default_behavior = "KEEP"
    
    filter {
      behavior = "DROP"
      condition {
        action_condition {
          action = "COUNT" # Count 된 로그는 버리기 (예시)
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}