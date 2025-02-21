resource "aws_cloudwatch_log_group" "main_ecs_cluster" {
  name              = "/aws/ecs/${format(local.resource_name, "main-cluster")}"
  retention_in_days = var.ecs_cw_retention_days
  tags              = merge(local.common_tags, { "Name" : "/aws/ecs/${format(local.resource_name, "main-ecs-cluster")}" })
}

resource "aws_ecs_cluster" "main" {
  name = format(local.resource_name, "main-cluster")
  setting {
    name  = "containerInsights"
    value = var.ecs_container_insights
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.main_ecs_cluster.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main_cluster_fargate_cp" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = [
    "FARGATE",
  ]
  default_capacity_provider_strategy {
    weight            = 100
    capacity_provider = "FARGATE"
  }
}