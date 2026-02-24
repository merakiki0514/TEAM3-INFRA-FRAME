# ----------- [General Log Bucket] -----------
output "bucket_id" {
  description = "일반 로그용 S3 버킷 이름"
  value       = module.s3_logs.bucket_id
}

output "bucket_arn" {
  description = "일반 로그용 S3 버킷 ARN"
  value       = module.s3_logs.bucket_arn
}

output "bucket_domain_name" {
  description = "일반 로그용 S3 버킷 도메인"
  value       = module.s3_logs.bucket_domain_name
}

# ----------- [WAF Log Bucket (추가됨)] -----------
output "waf_bucket_id" {
  description = "WAF 로그용 S3 버킷 이름 (aws-waf-logs-로 시작)"
  value       = module.waf_logs.bucket_id
}

output "waf_bucket_arn" {
  description = "WAF 로그용 S3 버킷 ARN"
  value       = module.waf_logs.bucket_arn
}