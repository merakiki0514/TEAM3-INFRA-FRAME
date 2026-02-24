terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
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