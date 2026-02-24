output "alb_dns_name" {
  description = "ALB 접속 주소 (브라우저 접속 테스트용)"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ALB ARN (07.waf 연결 시 필요)"
  value       = module.alb.alb_arn
}

output "alb_arn_suffix" {
  description = "CloudWatch 지표용 Suffix"
  value       = module.alb.alb_arn_suffix
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = module.alb.target_group_arn
}