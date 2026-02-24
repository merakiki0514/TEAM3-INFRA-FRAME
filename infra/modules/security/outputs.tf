# 생성되면 ID 반환, 안 만들어졌으면 null 반환

output "alb_sg_id" {
  value = try(aws_security_group.alb[0].id, null)
}

output "app_sg_id" {
  value = try(aws_security_group.app[0].id, null)
}

output "db_sg_id" {
  value = try(aws_security_group.db[0].id, null)
}

output "bastion_sg_id" {
  value = try(aws_security_group.bastion[0].id, null)
}
