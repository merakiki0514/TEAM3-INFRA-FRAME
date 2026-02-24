output "repository_urls" {
  description = "각 리포지토리의 푸시 URL (Map 형태)"
  # 결과 예시: { "team3-frontend" = "1234.dkr.ecr.../team3-frontend", ... }
  value       = module.ecr.repository_urls
}

output "registry_id" {
  description = "ECR Registry ID"
  value       = module.ecr.registry_id
}