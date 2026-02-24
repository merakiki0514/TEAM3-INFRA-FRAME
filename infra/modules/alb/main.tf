# 1. Load Balancer 생성
resource "aws_lb" "this" {
  name               = "${var.project_name}-${var.alb_name_suffix}"
  load_balancer_type = "application"
  internal           = var.internal
  security_groups    = var.security_groups
  subnets            = var.subnets

  # 운영 환경에서는 삭제 방지를 켜는 것이 좋습니다 (지금은 false)
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.alb_name_suffix}"
  }
}

# 2. Target Group 생성
resource "aws_lb_target_group" "this" {
  name     = "${var.project_name}-tg"
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  # 헬스 체크 설정 커스터마이징
  health_check {
    path                = var.health_check_path
    protocol            = var.target_group_protocol
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# 3. HTTP Listener (HTTP -> HTTPS 리다이렉트)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# 4. HTTPS Listener (메인 트래픽 처리)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # AWS 권장 기본 정책
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# 5. ASG Attachment (EKS Node Group의 ASG를 Target Group에 연결)
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}