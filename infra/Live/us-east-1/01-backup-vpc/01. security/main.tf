# 00-network 상태 참조
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../00. network/terraform.tfstate"
  }
}

module "security" {
  source = "../../../../modules/security"

  project_name = var.project_name
  vpc_id       = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr     = data.terraform_remote_state.network.outputs.vpc_cidr

  # DR 가동 시 필요한 SG들 활성화
  enable_db_sg      = true # 백업 DB
  
  # 필요 없는 것 비활성화
  enable_alb_sg     = false
  enable_app_sg     = false
  enable_bastion_sg = false
}