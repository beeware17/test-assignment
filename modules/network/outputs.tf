output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "backend_grpc_tg_arn" {
  value = aws_lb_target_group.backend_grpc_tg.arn
}

output "backend_sg_id" {
  value = aws_security_group.backend_alb_sg.id
}

output "backend_alb_arn" {
  value = aws_lb.backend_alb.arn
}

output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend_grpc_tg.arn
}

output "frontend_sg_id" {
  value = aws_security_group.frontend_alb_sg.id
}
output "frontend_alb_arn" {
  value = aws_lb.frontend_alb.arn
}