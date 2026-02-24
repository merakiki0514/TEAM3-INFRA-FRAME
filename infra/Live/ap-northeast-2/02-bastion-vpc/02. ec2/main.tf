# -----------------------------------------------------------------------
# 1. Remote State 참조 (Network & Security)
# -----------------------------------------------------------------------
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../00. network/terraform.tfstate"
  }
}

data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "../01. security/terraform.tfstate"
  }
}

# -----------------------------------------------------------------------
# 2. IAM Role & Policy (Bastion)
# -----------------------------------------------------------------------
resource "aws_iam_role" "bastion" {
  name = "${var.project_name}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# EKS 전체 관리 권한 (Admin for cluster creation/management)
resource "aws_iam_role_policy_attachment" "bastion_admin_attach" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# SSM Session Manager 접속 권한 (SSH 대체)
resource "aws_iam_role_policy_attachment" "bastion_ssm_attach" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Custom Policy: SSM Parameter Read & KMS Decrypt (For DB Password)
resource "aws_iam_policy" "bastion_ssm_read_policy" {
  name        = "${var.project_name}-bastion-ssm-read-policy"
  description = "Allow Bastion to read SSM parameters and decrypt KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "SSMParameterRead"
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters"]
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/*"
      },
      {
        Sid      = "KMSDecrypt"
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_read_attach" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.bastion_ssm_read_policy.arn
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-bastion-profile"
  role = aws_iam_role.bastion.name
}

# -----------------------------------------------------------------------
# 3. Bastion EC2 Instance
# -----------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami           = var.bastion_ami
  instance_type = "t3.micro"
  key_name      = var.key_pair

  # Public Subnet 배치
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  vpc_security_group_ids      = [data.terraform_remote_state.security.outputs.bastion_sg_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  # User Data: 설치 스크립트 (Ubuntu 기준)
  user_data = <<-EOF
    #!/bin/bash
    # 1. 기본 도구 설치
    apt-get update -y && apt-get upgrade -y
    apt-get install -y unzip curl git mysql-client

    # 2. SSM Agent (Ubuntu Snap)
    snap install amazon-ssm-agent --classic
    systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service
    
    # 3. AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    # 4. kubectl (v1.29)
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/kubectl

    # 5. Helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh

    # 6. eksctl
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
    mv /tmp/eksctl /usr/local/bin

    # 7. Docker
    apt-get install -y docker.io
    usermod -aG docker ubuntu
    
    echo "User Data Script Completed" > /var/log/user-data-status.txt
  EOF

  tags = {
    Name = "${var.project_name}-host"
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.project_name}-eip"
  }
}