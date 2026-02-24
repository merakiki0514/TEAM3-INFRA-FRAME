data "terraform_remote_state" "network" {
  backend = "local" 
  config = {
    # 현재 위치(01. security)에서 상위(..)로 가서 00. network로 진입
    path = "../00. network/terraform.tfstate"
  }
}

module "security" {
  source = "../../../../modules/security"

  project_name = var.project_name
  vpc_id       = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr     = data.terraform_remote_state.network.outputs.vpc_cidr

  # Bastion SG만 활성화
  enable_bastion_sg = true
  
  # 나머지는 비활성화
  enable_alb_sg     = false
  enable_app_sg     = false
  enable_db_sg      = false
}