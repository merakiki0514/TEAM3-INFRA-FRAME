output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "List of IDs of private app subnets"
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  description = "List of IDs of private db subnets"
  value       = aws_subnet.private_db[*].id
}

# NAT가 안 만들어질 수도 있으므로 try 처리 (없으면 null 반환)
output "nat_instance_id" {
  value = try(aws_instance.nat[0].id, null)
}

output "nat_public_ip" {
  value = try(aws_instance.nat[0].public_ip, null)
}