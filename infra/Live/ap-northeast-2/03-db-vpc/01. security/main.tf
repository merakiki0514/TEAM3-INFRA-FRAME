# 1. 내 네트워크 상태 (DB VPC)
data "terraform_remote_state" "network" {
  backend = "local"
  config = { path = "../00. network/terraform.tfstate" }
}

# 2. Main VPC 상태 (App SG ID 가져오기 위함)
data "terraform_remote_state" "main_vpc_security" {
  backend = "local"
  config = { path = "../../01-main-vpc/01. security/terraform.tfstate" }
}

# 3. Bastion VPC 상태 (Bastion SG ID 가져오기 위함)
data "terraform_remote_state" "bastion_vpc_security" {
  backend = "local"
  config = { path = "../../02-bastion-vpc/01. security/terraform.tfstate" }
}

module "security" {
  source = "../../../../modules/security"

  project_name = var.project_name
  vpc_id       = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr     = data.terraform_remote_state.network.outputs.vpc_cidr

  # DB SG만 활성화
  enable_db_sg = true
  
  # 나머지 비활성화
  enable_alb_sg     = false
  enable_app_sg     = false
  enable_bastion_sg = false

  # [접근 허용]
  # 1. Main VPC의 EKS App에서 오는 접근 허용 (Peering 필요)
  allowed_app_sg_ids = [data.terraform_remote_state.main_vpc_security.outputs.app_sg_id]
  # 2. Bastion VPC 접근 허용 (모듈 변수로 직접 전달!)
  # 별도의 resource 추가 없이, 이렇게 리스트로 넘기면 모듈 내부에서 처리됩니다.
  allowed_bastion_sg_ids = [data.terraform_remote_state.bastion_vpc_security.outputs.bastion_sg_id]
}