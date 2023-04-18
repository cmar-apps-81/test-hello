resource "aws_security_group" "alb-svc-cmar-com" {
  name        = "alb-svc-cmar-com"
  description = "Security Group for ALB"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb-svc-cmar-com" {
  name                       = "alb-svc-cmar-com"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-svc-cmar-com.id]
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false
  tags = {
    Environment = "svc"
  }
}

resource "aws_alb_target_group" "alb-svc-cmar-com_http" {
  name     = "alb-svc-cmar-com-http"
  vpc_id   = module.vpc.vpc_id
  port     = 31647
  protocol = "HTTP"
  health_check {
    path                = "/healthz"
    port                = 31647
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 4
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_target_group" "alb-svc-cmar-com_https" {
  name     = "alb-svc-cmar-com-https"
  vpc_id   = module.vpc.vpc_id
  port     = 30989
  protocol = "TLS"

  health_check {
    port                = 30989
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "alb-svc-cmar-com_http" {
  load_balancer_arn = aws_lb.alb-svc-cmar-com.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb-svc-cmar-com_http.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "alb-svc-cmar-com_https" {
  load_balancer_arn = aws_lb.alb-svc-cmar-com.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = module.acm-svc.this_acm_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.alb-svc-cmar-com_http.arn
    type             = "forward"
  }
}

module "acm-svc" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name          = "svc.cmar.io"
  zone_id              = data.aws_route53_zone.selected.id
  validate_certificate = true

  subject_alternative_names = ["*.svc.cmar.io"]

  tags = {
    Name = "svc.cmar.io"
  }
}
