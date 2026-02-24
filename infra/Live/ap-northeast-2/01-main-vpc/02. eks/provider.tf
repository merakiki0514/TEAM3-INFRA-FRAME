terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    # [필수 추가] Helm 프로바이더 정의가 있어야 블록 에러가 사라집니다.
    helm = {
      source  = "hashicorp/helm"
    # [수정] ">= 2.9" -> "2.17.0" (v3.0 금지!)
      version = "2.17.0"
    }
    # [필수 추가] IAM 정책 다운로드용 http 프로바이더
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  # access_key, secret_key 삭제됨 -> AWS CLI 설정(aws configure)을 자동으로 읽음

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Team      = "Team3"
      Env       = "Prod"
    }
  }
}

# [추가] Helm Provider 설정 (EKS 클러스터 접속 정보)
# [중요] Helm 프로바이더는 terraform {} 블록 바깥에 독립적으로 있어야 함!
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}