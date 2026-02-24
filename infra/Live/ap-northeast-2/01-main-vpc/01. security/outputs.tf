output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = module.security.alb_sg_id
}

output "app_sg_id" {
  description = "EKS Node (App) Security Group ID"
  value       = module.security.app_sg_id
}