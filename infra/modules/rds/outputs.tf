output "rds_endpoint" {
  description = "RDS Connection Endpoint"
  value       = aws_db_instance.this.address
}

output "rds_port" {
  value = aws_db_instance.this.port
}

output "rds_id" {
  value = aws_db_instance.this.id
}