output "bastion_public_ip" {
  description = "개발팀 접속용 IP 주소"
  value       = aws_eip.bastion.public_ip
}

output "ssh_command" {
  description = "접속 명령어 예시"
  value       = "ssh -i ${var.key_pair}.pem ubuntu@${aws_eip.bastion.public_ip}"
}

output "bastion_role_arn" {
  value = aws_iam_role.bastion.arn
}