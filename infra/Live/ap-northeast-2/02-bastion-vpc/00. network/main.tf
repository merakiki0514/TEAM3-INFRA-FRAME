module "network" {
  source = "../../../../modules/network"

  project_name = var.project_name
  aws_region   = var.aws_region
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs

  # Public Subnet만 생성
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = [] # 생성 안 함
  private_db_subnet_cidrs  = [] # 생성 안 함

  # Bastion VPC는 NAT Gateway 필요 없음 (Public EC2라서)
  enable_nat_instance  = false
  enable_ssm_endpoints = false
}