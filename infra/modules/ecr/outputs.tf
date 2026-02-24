output "repository_names" {
  description = "Map of repository names"
  value       = { for k, v in aws_ecr_repository.this : k => v.name }
}

output "repository_arns" {
  description = "Map of repository ARNs"
  value       = { for k, v in aws_ecr_repository.this : k => v.arn }
}

output "repository_urls" {
  description = "Map of repository URLs (for docker push)"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "registry_id" {
  description = "Registry ID (Common for all repos)"
  # 아무거나 하나 잡아서 ID 출력 (모두 동일하므로)
  value = length(aws_ecr_repository.this) > 0 ? values(aws_ecr_repository.this)[0].registry_id : null
}