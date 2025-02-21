locals {
  frontend_nextjs_component_name = format(local.resource_name, "frontend-nextjs")
}
resource "aws_ecs_task_definition" "frontend_nextjs" {
  family                   = local.frontend_nextjs_component_name
  cpu                      = var.frontend_nextjs_service_task_cpu
  memory                   = var.frontend_nextjs_service_task_memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_services_common_task_exec_role.arn
  task_role_arn            = aws_iam_role.frontend_sqs_task_role.arn
  container_definitions = jsonencode(yamldecode(templatefile("${path.module}/templates/frontend_nextjs.tpl",
    {
      container_name            = local.frontend_nextjs_component_name
      frontend_nextjs_image_url = var.frontend_nextjs_image_url
      sqs_address               = var.sqs_address

      aws_region        = var.aws_region
      log_group         = aws_cloudwatch_log_group.main_ecs_cluster.name
      log_stream_prefix = local.frontend_nextjs_component_name

    }))
  )
  tags = local.common_tags
}

resource "aws_ecs_service" "frontend_nextjs" {
  name            = local.frontend_nextjs_component_name
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.frontend_nextjs.arn
  desired_count   = 1
  propagate_tags  = "TASK_DEFINITION"

  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

  network_configuration {
    security_groups  = [aws_security_group.frontend_nextjs_service.id]
    subnets          = var.private_subnets_ids
    assign_public_ip = false
  }

  load_balancer {
    container_name   = local.frontend_nextjs_component_name
    container_port   = 80
    target_group_arn = var.frontend_nextjs_tg_arn
  }
}
### End ECS Part

### SG part
resource "aws_security_group" "frontend_nextjs_service" {
  name        = local.frontend_nextjs_component_name
  description = "Security group for backend sqs service"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = local.frontend_nextjs_component_name })
}

resource "aws_vpc_security_group_ingress_rule" "frontend_service_allow_from_frontend_alb_sg" {
  description                  = "Allow http traffic from Frontend LB to Frontend Service"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = var.frontend_alb_sg_id
  security_group_id            = aws_security_group.frontend_nextjs_service.id
}

resource "aws_vpc_security_group_egress_rule" "frontend_nextjs_egress_allow_all" {
  description       = "Allow all egress connections"
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.frontend_nextjs_service.id
}
### End SG part
### Application Auto Scaling Target for Frontend ###
resource "aws_appautoscaling_target" "frontend_nextjs" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.frontend_nextjs.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

### Latency-Based Auto Scaling Policy for Frontend Part
resource "aws_appautoscaling_policy" "frontend_nextjs_latency" {
  name               = "frontend-nextjs-latency-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend_nextjs.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend_nextjs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend_nextjs.service_namespace

  target_tracking_scaling_policy_configuration {
    customized_metric_specification {
      metric_name = "TargetResponseTime"
      namespace   = "AWS/ApplicationELB"
      statistic   = "Average"
      unit        = "Seconds"

      dimensions {
        name  = "TargetGroup"
        value = var.frontend_nextjs_tg_arn
      }

      dimensions {
        name  = "LoadBalancer"
        value = var.frontend_alb_arn
      }
    }

    target_value       = 0.5  # In seconds
    scale_in_cooldown  = 60
    scale_out_cooldown = 30
  }
}
