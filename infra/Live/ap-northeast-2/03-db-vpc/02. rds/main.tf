# Network, Security 상태 참조
data "terraform_remote_state" "network" {
  backend = "local"
  config = { path = "../00. network/terraform.tfstate" }
}

data "terraform_remote_state" "security" {
  backend = "local"
  config = { path = "../01. security/terraform.tfstate" }
}

module "rds" {
  source = "../../../../modules/rds"

  project_name = var.project_name
  vpc_id       = data.terraform_remote_state.network.outputs.vpc_id
  
  # DB Subnet 및 SG 주입
  private_db_subnet_ids = data.terraform_remote_state.network.outputs.private_db_subnet_ids
  db_sg_id              = data.terraform_remote_state.security.outputs.db_sg_id

  # DB 설정
  db_identifier        = "team3-prod-db"
  db_name              = "team3db"
  db_username          = "admin"
  db_password_ssm_name = var.db_password_ssm_name
  
  instance_class       = "db.t3.micro"
  multi_az             = true  # 고가용성 (운영 환경 권장)
  skip_final_snapshot  = true  # 실습용 (운영 시 false 권장)
}