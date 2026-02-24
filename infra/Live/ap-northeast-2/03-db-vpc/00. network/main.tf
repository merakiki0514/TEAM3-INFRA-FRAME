module "network" {
  source = "../../../../modules/network"

  project_name = var.project_name
  aws_region   = var.aws_region
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs

  # DB 전용 Subnet만 생성
  private_db_subnet_cidrs = var.private_db_subnet_cidrs
  
  # 나머지는 생성 안 함 (보안 강화)
  public_subnet_cidrs      = []
  private_app_subnet_cidrs = []

  # 외부 통신 불필요
  enable_nat_instance  = false
  enable_ssm_endpoints = false
}