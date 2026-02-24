output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

# [핵심] iam_irsa 모듈에서 사용할 URL
output "oidc_url" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# [핵심] iam_irsa 모듈에서 사용할 Provider ARN
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

# [추가] ALB 연결을 위해 Node Group의 ASG 이름 출력
output "node_group_asg_names" {
  description = "EKS Node Group의 ASG 이름 목록"
  # 단일 리소스이므로 for 루프 없이 직접 접근하여 리스트로 만듭니다.
  value = [aws_eks_node_group.this.resources[0].autoscaling_groups[0].name]
}

# [추가] EKS가 자동으로 생성한 Cluster Security Group ID 내보내기
output "cluster_security_group_id" {
  description = "Security Group ID created by EKS for the cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# [추가] LBC 설치를 위해 OIDC URL을 밖으로 내보내기
output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
