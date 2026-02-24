# -----------------------------------------------------------------------
# Network 모듈 호출
# -----------------------------------------------------------------------
module "network" {
  # [중요] 모듈 파일이 있는 상대 경로 (폴더 깊이에 따라 ../ 개수 주의)
  source = "../../../../modules/network"

  # 1. 기본 설정 주입
  project_name = var.project_name
  aws_region   = var.aws_region
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs

  # 2. 서브넷 설정 주입
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = [] # 빈 리스트 전달됨

  # 3. NAT & SSM 설정 (정석대로 모듈 내부에서 처리)
  enable_nat_sg     = true   # nat Instance용
  enable_nat_instance  = true
  enable_ssm_endpoints = true

  # 4. 인스턴스 설정
  nat_instance_ami = var.nat_instance_ami
  key_pair         = var.key_pair
  
  # NAT 인스턴스용 SG ID는 모듈이 알아서 생성하므로 입력하지 않음 (null)
  nat_sg_id     = null 

  # 5. NAT UserData (IP 포워딩 필수 스크립트)
  nat_userdata = <<-EOF
    #!/bin/bash
    # 1. 커널 레벨 IP 포워딩 활성화 (sudo 권한으로 파일 쓰기)
    sudo sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
    sudo sysctl -p

    # 2. iptables 서비스 설치
    sudo yum install -y iptables-services

    # 3. 기존 규칙 초기화 (깨끗한 상태에서 시작)
    sudo iptables -F
    sudo iptables -t nat -F

    # -------------------------------------------------------------
    # [핵심] 마스커레이딩 (SNAT) - 내부 서버가 인터넷으로 나갈 수 있게 해줌
    # -------------------------------------------------------------
    # eth0 또는 ens5 인터페이스를 통해 나가는 패킷의 주소를 NAT Instance의 IP로 변조
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null
    sudo iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE 2>/dev/null
    sudo iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1460

    # 4. FORWARD 체인 허용
    # (들어오는 패킷을 다른 곳으로 패스해주는 기능 허용)
    sudo iptables -P FORWARD ACCEPT

    # 5. 설정 저장 및 서비스 활성화 (재부팅 후에도 유지)
    sudo service iptables save
    sudo systemctl enable iptables
    sudo systemctl start iptables
  EOF
}