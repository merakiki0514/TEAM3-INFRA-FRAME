# -----------------------------------------------------------------------
# ECR 모듈 호출
# -----------------------------------------------------------------------
module "ecr" {
  source = "../../../../modules/ecr"

  project_name = var.project_name
  
  # [리포지토리 목록 주입]
  repository_names = var.repository_names

  # [설정]
  image_tag_mutability    = "MUTABLE" # 같은 태그(latest) 덮어쓰기 허용
  scan_on_push            = true      # 푸시할 때마다 보안 스캔
  enable_lifecycle_policy = true      # 오래된 이미지 자동 삭제
  image_count_retention   = 10        # 최근 30개만 유지 (비용 절감)
  force_delete            = true      # 리포지토리 삭제 시 내부 이미지도 강제 삭제 (편의상 true)
}