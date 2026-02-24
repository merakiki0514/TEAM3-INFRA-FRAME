# -----------------------------------------------------------------------
# [참조 1] 00-network 상태 읽기 (VPC, Subnet 정보)
# -----------------------------------------------------------------------
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../00. network/terraform.tfstate"
  }
}

# -----------------------------------------------------------------------
# [참조 2] 01-security 상태 읽기 (App SG 정보)
# -----------------------------------------------------------------------
data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "../01. security/terraform.tfstate"
  }
}
# -----------------------------------------------------------------------
# [추가] DB VPC의 Security Group 상태 읽기
# -----------------------------------------------------------------------
data "terraform_remote_state" "db_security" {
  backend = "local"
  config = {
    path = "../../03-db-vpc/01. security/terraform.tfstate"
  }
}

# -----------------------------------------------------------------------
# [추가] Bastion Security 상태 읽기 (SSH 접속 허용용)
# -----------------------------------------------------------------------
data "terraform_remote_state" "bastion_security" {
  backend = "local"
  config = {
    # Bastion VPC의 01.security 경로 (공백 유무 주의: 사용자 환경에 맞춤)
    path = "../../02-bastion-vpc/01. security/terraform.tfstate"
  }
}

# EKS 클러스터 이름 태그(kubernetes.io/cluster/<이름> = owned)를 기반으로 ASG 검색
data "aws_autoscaling_groups" "eks_node_groups" {
  filter {
    name   = "tag:kubernetes.io/cluster/${module.eks.cluster_name}"
    values = ["owned"]
  }
}

# -----------------------------------------------------------------------
# EKS 모듈 호출
# -----------------------------------------------------------------------
module "eks" {
  source = "../../../../modules/eks"

  project_name    = var.project_name
  cluster_version = var.cluster_version

  # [Network 정보 주입]
  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  # EKS Node는 Private Subnet에 배치하는 것이 정석입니다.
  subnet_ids = data.terraform_remote_state.network.outputs.private_app_subnet_ids

  # [Security 정보 주입]
  # 기본 클러스터 SG 외에 App 전용 SG를 추가로 붙입니다.
  cluster_sg_ids = [data.terraform_remote_state.security.outputs.app_sg_id]
  
  # [Bastion 접근 설정]
  # 현재 Bastion VPC가 없으므로 일단 null로 둡니다.
  # 추후 Bastion 구축 후 Peering 연결 시 Bastion SG ID를 여기에 넣어주면 SSH 접속이 가능해집니다.
  bastion_sg_id = data.terraform_remote_state.bastion_security.outputs.bastion_sg_id

  # [Node Group 설정]
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  key_pair            = "Team3_project_seoul"
}

# -----------------------------------------------------------------------
# [Bastion 권한 연결] Bastion Role을 EKS 관리자로 등록
# -----------------------------------------------------------------------

# 1. Bastion 상태값 읽기
# 위치: 02. eks -> (상위) 01-main-vpc -> (상위) ap-northeast-2 -> (하위) 02-bastion-vpc -> 02. ec2
data "terraform_remote_state" "bastion" {
  backend = "local"
  
  config = {
    # 폴더 깊이에 맞춰 상위 폴더로 두 번(../..) 올라가야 합니다.
    # Bastion Role은 '02. ec2' 폴더에서 생성되므로 해당 경로의 tfstate를 바라봐야 합니다.
    path = "../../02-bastion-vpc/02. ec2/terraform.tfstate"
  }
}

# 2. Access Entry 생성 (Bastion Role -> EKS 연결)
resource "aws_eks_access_entry" "bastion_admin" {
  # [체크] EKS 모듈 정의할 때 이름을 module "eks" { ... } 로 했는지 확인하세요.
  cluster_name  = module.eks.cluster_name 
  
  # Bastion State의 output 이름이 'bastion_role_arn'인지 꼭 확인하세요!
  principal_arn = data.terraform_remote_state.bastion.outputs.bastion_role_arn 
  type          = "STANDARD"
}

# 3. 관리자 권한(ClusterAdmin) 정책 연결
resource "aws_eks_access_policy_association" "bastion_admin_policy" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.terraform_remote_state.bastion.outputs.bastion_role_arn

  access_scope {
    type = "cluster"
  }
}

# -----------------------------------------------------------------------
# [추가] RDS 접근 허용 규칙 (EKS Node -> RDS)
# -----------------------------------------------------------------------
resource "aws_security_group_rule" "allow_eks_nodes_to_rds" {
  description = "Allow EKS Nodes to access RDS"
  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"

  # 1. 규칙을 추가할 대상: DB 보안 그룹 (Destination)
  security_group_id = data.terraform_remote_state.db_security.outputs.db_sg_id

  # 2. 허용할 소스: EKS Node Security Group (Source)
  source_security_group_id = module.eks.cluster_security_group_id
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# -----------------------------------------------------------------------
# 1. AWS Load Balancer Controller용 IAM 정책 다운로드 (AWS 공식)
# -----------------------------------------------------------------------
data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json"
}

# -----------------------------------------------------------------------
# 2. IAM Policy 생성
# -----------------------------------------------------------------------
resource "aws_iam_policy" "lb_controller" {
  name        = "${var.project_name}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  policy      = data.http.iam_policy.response_body
}

# -----------------------------------------------------------------------
# 3. IAM Role 생성 (Trust Relationship: OIDC)
# -----------------------------------------------------------------------
data "aws_iam_policy_document" "lb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "lb_controller" {
  name               = "${var.project_name}-eks-lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_assume_role.json
}

# -----------------------------------------------------------------------
# 4. Role에 Policy 연결
# -----------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  policy_arn = aws_iam_policy.lb_controller.arn
  role       = aws_iam_role.lb_controller.name
}

# -----------------------------------------------------------------------
# 5. Helm Chart 설치 (컨트롤러 배포)
# -----------------------------------------------------------------------
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.1"

  # 중요: 의존성 설정
  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.lb_controller_attach
  ]

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller.arn
  }
  
  # VPC ID는 변수명에 맞춰서 수정하세요 (보통 var.vpc_id)
  set {
    name  = "vpc_Id"
    value = data.terraform_remote_state.network.outputs.vpc_id
  }
  set {
    name  = "region"
    value = var.aws_region
  }
}