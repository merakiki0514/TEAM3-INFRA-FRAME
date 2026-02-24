# -----------------------------------------------------------------------
# [중요] 00-network의 상태값(VPC ID 등) 읽어오기
# -----------------------------------------------------------------------
data "terraform_remote_state" "network" {
  backend = "local" # S3 Backend 사용 시 수정 필요
  config = {
    path = "../00. network/terraform.tfstate"
  }
}

# [신규 추가] Bastion 상태 읽기
data "terraform_remote_state" "bastion" {
  backend = "local"
  config = {
    # 경로: Main VPC -> Region -> Bastion VPC -> 01. security
    path = "../../02-bastion-vpc/01. security/terraform.tfstate"
  }
}

# -----------------------------------------------------------------------
# Security 모듈 호출
# -----------------------------------------------------------------------
module "security" {
  source = "../../../../modules/security"
  project_name = var.project_name
  
  # Network 모듈에서 출력한 값 주입
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr = data.terraform_remote_state.network.outputs.vpc_cidr

  # ----------- [Main VPC에 필요한 SG 활성화] -----------
  enable_alb_sg     = true  # ALB용
  enable_app_sg     = true  # EKS Node(App)용

  # ----------- [비활성화] -----------
  enable_db_sg      = false # RDS용 (DB VPC에 RDS를 둠)
  enable_bastion_sg = false # Bastion Host는 02-bastion-vpc에 위치함

  # ----------- [외부 의존성 주입] -----------
  # 반드시 bastion의 security 먼저 실행후 실행
  allowed_bastion_sg_ids = [data.terraform_remote_state.bastion.outputs.bastion_sg_id]
  # ALB SG는 모듈 내부에서 자동으로 App SG 규칙에 추가됩니다.
}