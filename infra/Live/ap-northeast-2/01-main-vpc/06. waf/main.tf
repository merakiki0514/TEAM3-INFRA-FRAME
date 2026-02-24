# -----------------------------------------------------------------------
# [참조 1] 04-alb 상태 읽기 (ALB ARN 필요)
# -----------------------------------------------------------------------
data "terraform_remote_state" "alb" {
  backend = "local"
  config = {
    path = "../04. alb/terraform.tfstate"
  }
}

# -----------------------------------------------------------------------
# [참조 2] 06-s3 상태 읽기 (WAF 로그 버킷 ARN 필요)
# -----------------------------------------------------------------------
data "terraform_remote_state" "s3" {
  backend = "local"
  config = {
    path = "../06. s3/terraform.tfstate"
  }
}

# -----------------------------------------------------------------------
# WAF 모듈 호출
# -----------------------------------------------------------------------
module "waf" {
  source = "../../../../modules/waf"

  project_name = var.project_name
  scope        = var.scope

  # [연결 대상] 04-alb에서 만든 ALB의 ARN을 주입 -> 자동으로 연결됨
  alb_arn      = data.terraform_remote_state.alb.outputs.alb_arn

  # [보안 규칙 설정]
  # AWS 관리형 규칙(Managed Rules) 중 가장 기본이 되는 CommonRuleSet 적용
  managed_rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 10
      vendor   = "AWS"
    },
  # 2. SQL Injection 방어 규칙 (추가 예시)
    /*{
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 20
      vendor   = "AWS"
    },
  # 3. 리눅스 취약점 방어 규칙 (추가 예시)
    {
      name     = "AWSManagedRulesLinuxRuleSet"
      priority = 30
      vendor   = "AWS"
    }
    */
    /*
    규칙 추가 시 주의사항:

    Priority(우선순위): 모든 규칙은 유일한 숫자를 가져야 합니다. (예: 10, 20, 30...). 숫자가 낮을수록 먼저 평가됩니다.

    Name & Vendor: AWS 관리형 규칙의 정확한 이름을 입력해야 합니다.

    AWSManagedRulesCommonRuleSet (일반적인 공격)

    AWSManagedRulesSQLiRuleSet (SQL 인젝션)

    AWSManagedRulesKnownBadInputsRuleSet (나쁜 입력값)

    AWSManagedRulesLinuxRuleSet (리눅스 관련 취약점)
    */
  ]
}