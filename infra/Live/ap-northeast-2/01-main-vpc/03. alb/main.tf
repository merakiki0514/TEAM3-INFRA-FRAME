# -----------------------------------------------------------------------
# [참조 1] 00-network 상태 읽기 (VPC, Public Subnet)
# -----------------------------------------------------------------------
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../00. network/terraform.tfstate"
  }
}

# -----------------------------------------------------------------------
# [참조 2] 01-security 상태 읽기 (ALB SG)
# -----------------------------------------------------------------------
data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "../01. security/terraform.tfstate"
  }
}

# -----------------------------------------------------------------------
# [참조 3] EKS 상태 읽기 (ASG 이름 가져오기)
# -----------------------------------------------------------------------
data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../02. eks/terraform.tfstate" 
  }
}

# -----------------------------------------------------------------------
# [신규] AWS ACM 인증서 정보 조회 (시스템적으로 가져오기)
# -----------------------------------------------------------------------
data "aws_acm_certificate" "this" {
  domain      = var.domain_name  # 변수에서 입력받은 도메인으로 검색
  statuses    = ["ISSUED"]       # '발급 완료'된 인증서만 검색
  most_recent = true             # 여러 개라면 가장 최신 것 선택
}

# -----------------------------------------------------------------------
# ALB 모듈 호출
# -----------------------------------------------------------------------
module "alb" {
  source = "../../../../modules/alb"

  project_name = var.project_name
  
  # [Network 정보 주입]
  vpc_id  = data.terraform_remote_state.network.outputs.vpc_id
  # ALB는 외부 접근을 위해 반드시 Public Subnet에 배치해야 합니다.
  subnets = data.terraform_remote_state.network.outputs.public_subnet_ids

  # [Security 정보 주입]
  security_groups = [data.terraform_remote_state.security.outputs.alb_sg_id]

  # [설정]
  internal            = false   # 외부(Internet)용
  target_group_port   = var.target_group_port
  target_group_protocol = "HTTP" # SSL Termination은 ALB에서 하므로 NodePort 통신은 내부적으로 HTTP 사용
  health_check_path   = var.health_check_path

  # -----------------------------------------------------------
  # [수정됨] HTTPS 및 ASG 연결 설정
  # -----------------------------------------------------------
  
  # 1. 시스템이 조회한 ACM 인증서의 ARN을 자동으로 주입
  acm_certificate_arn = data.aws_acm_certificate.this.arn
  
  # 2. EKS Node Group의 ASG 이름 (이전과 동일)
  asg_name            = data.terraform_remote_state.eks.outputs.node_group_asg_name
  
}


