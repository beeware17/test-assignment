locals {
  backend_sqs_component_name = format(local.resource_name, "backend-sqs")
}
resource "aws_ecs_task_definition" "backend_sqs" {
  family                   = local.backend_sqs_component_name
  cpu                      = var.backend_sqs_service_task_cpu
  memory                   = var.backend_sqs_service_task_memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_services_common_task_exec_role.arn
  task_role_arn            = aws_iam_role.backend_sqs_task_role.arn
  container_definitions = jsonencode(yamldecode(templatefile("${path.module}/templates/backend_sqs.tpl",
    {
      container_name        = local.backend_sqs_component_name
      backend_sqs_image_url = var.backend_sqs_image_url
      sqs_address           = var.sqs_address

      aws_region        = var.aws_region
      log_group         = aws_cloudwatch_log_group.main_ecs_cluster.name
      log_stream_prefix = local.backend_sqs_component_name

    }))
  )
  tags = local.common_tags
}

resource "aws_ecs_service" "backend_sqs" {
  name            = local.backend_sqs_component_name
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.backend_sqs.arn
  desired_count   = 1
  propagate_tags  = "TASK_DEFINITION"

  enable_execute_command = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

  network_configuration {
    security_groups  = [aws_security_group.backend_sqs_service.id]
    subnets          = var.private_subnets_ids
    assign_public_ip = false
  }
}
### End ECS Part

### SG part
resource "aws_security_group" "backend_sqs_service" {
  name        = local.backend_sqs_component_name
  description = "Security group for backend sqs service"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = local.backend_sqs_component_name })
}

resource "aws_vpc_security_group_egress_rule" "backend_sqs_egress_allow_all" {
  description       = "Allow all egress connections"
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.backend_sqs_service.id
}
### End SG part

### Application Auto Scaling Target for Backend SQS
resource "aws_appautoscaling_target" "backend_sqs" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend_sqs.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

### SQS-Based Auto Scaling Policy for Backend Part
resource "aws_appautoscaling_policy" "backend_sqs_messages_in_flight" {
  name               = "backend-sqs-messages-in-flight-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend_sqs.resource_id
  scalable_dimension = aws_appautoscaling_target.backend_sqs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend_sqs.service_namespace

  target_tracking_scaling_policy_configuration {
    customized_metric_specification {
      metric_name = "ApproximateNumberOfMessagesNotVisible"
      namespace   = "AWS/SQS"
      statistic   = "Average"
      unit        = "Count"

      dimensions {
        name  = "QueueName"
        value = var.sqs_address
      }
    }

    target_value       = 50  # Amount of messages
    scale_in_cooldown  = 60
    scale_out_cooldown = 30
  }
}
