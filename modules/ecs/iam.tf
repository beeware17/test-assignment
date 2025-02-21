### Task EXEC part
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    sid = "AllowAssumeRoleForECS"
    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com", "ecs-tasks.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ecs_services_common_task_exec_policy" {
  statement {
    sid    = "AllowECRActions"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "AllowIAMPassRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_services_common_task_exec_policy" {
  name        = format(local.resource_name, "common-ecs-task-exec-policy")
  path        = "/"
  description = "Policy for ECS agent to be able to execute tasks in service"
  policy      = data.aws_iam_policy_document.ecs_services_common_task_exec_policy.json
  tags        = merge(local.common_tags, { Name : format(local.resource_name, "common-ecs-task-exec") })
}

resource "aws_iam_role" "ecs_services_common_task_exec_role" {
  name                  = format(local.resource_name, "common-ecs-task-exec-role")
  path                  = "/"
  description           = "Role for ECS agent to be able to execute tasks in service"
  assume_role_policy    = data.aws_iam_policy_document.ecs_assume_role.json
  force_detach_policies = true
  tags = merge(local.common_tags, {
    Name : format(local.resource_name, "common-ecs-task-exec-role")
  })
}

resource "aws_iam_role_policy_attachment" "common_ecs_service_task_execution_attachment" {
  role       = aws_iam_role.ecs_services_common_task_exec_role.name
  policy_arn = aws_iam_policy.ecs_services_common_task_exec_policy.arn
}
### End Task EXEC part

### Task permission part
data "aws_iam_policy_document" "backend_sqs_task_policy" {
  statement {
    sid    = "AllowECRActions"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes"
    ]
    resources = [var.sqs_arn]
  }
}

resource "aws_iam_policy" "backend_sqs_task_policy" {
  name        = format(local.resource_name, "backend-sqs-ecs-task-policy")
  path        = "/"
  description = "Policy for ECS task to be able to execute actions"
  policy      = data.aws_iam_policy_document.backend_sqs_task_policy.json
  tags        = merge(local.common_tags, { Name : format(local.resource_name, "backend-sqs-ecs-task-policy") })
}

resource "aws_iam_role" "backend_sqs_task_role" {
  name                  = format(local.resource_name, "backend-sqs-ecs-task-role")
  path                  = "/"
  description           = "Role for ECS task to be able to execute actions"
  assume_role_policy    = data.aws_iam_policy_document.ecs_assume_role.json
  force_detach_policies = true
  tags = merge(local.common_tags, {
    Name : format(local.resource_name, "backend-sqs-ecs-task-role")
  })
}

resource "aws_iam_role_policy_attachment" "backend_sqs_task_role_attachment" {
  role       = aws_iam_role.backend_sqs_task_role.name
  policy_arn = aws_iam_policy.backend_sqs_task_policy.arn
}
### End Task permission part


### Task permission part
data "aws_iam_policy_document" "frontend_sqs_task_policy" {
  statement {
    sid    = "AllowECRActions"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes"
    ]
    resources = [var.sqs_arn]
  }
}

resource "aws_iam_policy" "frontend_sqs_task_policy" {
  name        = format(local.resource_name, "frontend-sqs-ecs-task-policy")
  path        = "/"
  description = "Policy for ECS task to be able to execute actions"
  policy      = data.aws_iam_policy_document.frontend_sqs_task_policy.json
  tags        = merge(local.common_tags, { Name : format(local.resource_name, "frontend-sqs-ecs-task-policy") })
}

resource "aws_iam_role" "frontend_sqs_task_role" {
  name                  = format(local.resource_name, "frontend-sqs-ecs-task-role")
  path                  = "/"
  description           = "Role for ECS task to be able to execute actions"
  assume_role_policy    = data.aws_iam_policy_document.ecs_assume_role.json
  force_detach_policies = true
  tags = merge(local.common_tags, {
    Name : format(local.resource_name, "frontend-sqs-ecs-task-role")
  })
}

resource "aws_iam_role_policy_attachment" "frontend_sqs_task_role_attachment" {
  role       = aws_iam_role.frontend_sqs_task_role.name
  policy_arn = aws_iam_policy.frontend_sqs_task_policy.arn
}