output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API Endpoint (kubectl 접속용)"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Cluster CA Data"
  value       = module.eks.cluster_certificate_authority_data
}

# -----------------------------------------------------------------------
# [필수] 다음 단계(03.iam-irsa)를 위한 OIDC 정보
# -----------------------------------------------------------------------
output "oidc_url" {
  description = "EKS OIDC Issuer URL"
  value       = module.eks.oidc_url
}

output "oidc_provider_arn" {
  description = "IAM OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

# -----------------------------------------------------------------------
# [수정] 검색된 ASG 목록 중 첫 번째 이름을 내보내기
# -----------------------------------------------------------------------
output "node_group_asg_name" {
  description = "EKS Node Group ASG Name"
  # 검색된 ASG 이름 리스트(names) 중 첫 번째([0])를 가져옵니다.
  # try 함수를 써서 만약 못 찾더라도 에러 대신 빈 값("")을 내보내 안전하게 처리합니다.
  value       = try(data.aws_autoscaling_groups.eks_node_groups.names[0], "")
}