output "vpc_id" {
  value = module.network.vpc_id
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "private_db_subnet_ids" {
  value = module.network.private_db_subnet_ids
}