output "vpc_id" {
  description = "생성된 VPC ID (다른 모듈에서 참조)"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "ALB 등이 사용할 Public Subnet ID 목록"
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "EKS Node가 배치될 Private Subnet ID 목록"
  value       = module.network.private_app_subnet_ids
}

# NAT가 잘 떴는지 확인하기 위해 공인 IP 출력
output "nat_public_ip" {
  value = module.network.nat_public_ip
}