resource "aws_security_group" "frontend_alb_sg" {
  name        = format(local.resource_name, "frontent-alb-sg")
  description = "Security group for Frontend ALB"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = format(local.resource_name, "frontent-alb-sg") })
}

resource "aws_vpc_security_group_ingress_rule" "frontend_alb_allow_http_from_cloud_front" {
  for_each          = var.cloudfront_public_ips
  description       = "Allow http traffic to Frontend LB from CloudFront IPs"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.frontend_alb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "frontend_alb_allow_https_from_cloud_front" {
  for_each          = var.cloudfront_public_ips
  description       = "Allow https traffic to Frontend LB from CloudFront IPs"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 80
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.frontend_alb_sg.id
}

resource "aws_lb" "frontend_alb" {
  name               = format(local.resource_name, "frontent-alb")
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  security_groups    = [aws_security_group.frontend_alb_sg.id]
  tags               = merge(local.common_tags, { Name = format(local.resource_name, "frontent-alb") })
}

resource "aws_lb_listener" "frontend_alb_listener_80" {
  load_balancer_arn = aws_lb.frontend_alb.arn
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

resource "aws_lb_target_group" "frontend_grpc_tg" {
  name        = format(local.resource_name, "frontend-tg")
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

# TODO: Add certificate
# resource "aws_lb_listener" "frontend_alb_listener_443" {
#   load_balancer_arn = aws_lb.frontend_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = data.aws_acm_certificate.somecert.arn
#   default_action {
#     type = "forward"
#     ....
#
#   }
# }


resource "aws_security_group" "backend_alb_sg" {
  name        = format(local.resource_name, "backend-alb-sg")
  description = "Security group for Backend ALB"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.common_tags, { Name = format(local.resource_name, "backend-alb-sg") })
}

resource "aws_vpc_security_group_ingress_rule" "backend_alb_allow_http_from_cloud_front" {
  for_each          = var.cloudfront_public_ips
  description       = "Allow http traffic to Backend LB from CloudFront IPs"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.backend_alb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "backend_alb_allow_https_from_cloud_front" {
  for_each          = var.cloudfront_public_ips
  description       = "Allow https traffic to Backend LB from CloudFront IPs"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 80
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.backend_alb_sg.id
}

resource "aws_lb" "backend_alb" {
  name               = format(local.resource_name, "backend-alb")
  internal           = true
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  security_groups    = [aws_security_group.backend_alb_sg.id]
  tags               = merge(local.common_tags, { Name = format(local.resource_name, "backend-alb") })
}

resource "aws_lb_listener" "backend_alb_listener_80" {
  load_balancer_arn = aws_lb.backend_alb.arn
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


resource "aws_lb_target_group" "backend_grpc_tg" {
  name        = format(local.resource_name, "backend-grpc-tg")
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}


# TODO: Add certificate
# resource "aws_lb_listener" "backend_alb_listener_443" {
#   load_balancer_arn = aws_lb.backend__alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = data.aws_acm_certificate.somecert.arn
#   default_action {
#    type = "forward"
#     .....
#  }
# }