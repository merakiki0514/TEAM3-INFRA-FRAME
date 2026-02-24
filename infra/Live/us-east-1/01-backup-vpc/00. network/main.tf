module "network" {
  source = "../../../../modules/network"

  project_name = var.project_name
  aws_region   = var.aws_region
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs

  public_subnet_cidrs      = []
  private_app_subnet_cidrs = []
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs # 백업 VPC(RDS)

  # DR 상황 대비 NAT 구성
  enable_nat_instance  = false
  enable_ssm_endpoints = false

  nat_instance_ami = null
  key_pair         = null
  nat_sg_id     = null
  vpc_ssm_sg_id = null
  nat_userdata = ""
}