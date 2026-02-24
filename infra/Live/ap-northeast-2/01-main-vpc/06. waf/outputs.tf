output "web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = module.waf.web_acl_arn
}

output "web_acl_id" {
  description = "WAF Web ACL ID"
  value       = module.waf.web_acl_id
}

output "web_acl_capacity" {
  description = "사용 중인 WCU (Web ACL Capacity Units)"
  value       = module.waf.web_acl_capacity
}