### Common variables
variable "aws_region" {
  description = "AWS region name for terraform provider"
  type        = string
}

variable "environment" {
  description = "Environment name for naming"
  type        = string

  validation {
    condition     = var.environment == "development" || var.environment == "production"
    error_message = "Environment must be either development or production"
  }
}

### Network
variable "vpc_id" {
  description = "VPC ID for Security Group"
  type        = string
}

variable "private_subnets_ids" {
  description = "Private subnets IDs for Fargate placement"
  type        = list(any)
}

### ECS
variable "ecs_container_insights" {
  description = "Option to enable ECS Container Insights for ECS Cluster"
  type        = string
  default     = "disabled"
}

### CW
variable "ecs_cw_retention_days" {
  type        = number
  description = "CW log retention in days"
  default     = 14
}

### Backend SQS Service
variable "backend_sqs_service_task_cpu" {
  description = "CPU for Backend SQS Fargate task. Make sure that compatible with memory"
  type        = number
  default     = 256
}

variable "backend_sqs_service_task_memory" {
  description = "Memory for Backend SQS Fargate task. Make sure that compatible with CPU"
  type        = number
  default     = 512
}

variable "backend_sqs_image_url" {
  description = "Container image URL for ECS task"
  type        = string
}

variable "sqs_address" {
  description = "SQS Address for Backend Service Application"
  type        = string
}

variable "sqs_arn" {
  description = "SQS ARN for IAM"
  type        = string
}

### Backend gRPC Service
variable "backend_grpc_service_task_cpu" {
  description = "CPU for Backend gRPC Fargate task. Make sure that compatible with memory"
  type        = number
  default     = 256
}

variable "backend_grpc_service_task_memory" {
  description = "Memory for Backend gRPC Fargate task. Make sure that compatible with CPU"
  type        = number
  default     = 512
}

variable "backend_grpc_image_url" {
  description = "Container image URL for ECS task"
  type        = string
}

variable "backend_grpc_tg_arn" {
  description = "Target group ARN for backend grpc ECS Service"
  type        = string
}

variable "backend_alb_sg_id" {
  description = "Security group ID of backend ALB to allow access to service"
  type        = string
}

variable "backend_alb_arn" {
  description = "Backend ALB ARN for Latency scaling"
  type        = string
}

### Frontend NextJS Service
variable "frontend_nextjs_service_task_cpu" {
  description = "CPU for Backend gRPC Fargate task. Make sure that compatible with memory"
  type        = number
  default     = 256
}

variable "frontend_nextjs_service_task_memory" {
  description = "Memory for Backend gRPC Fargate task. Make sure that compatible with CPU"
  type        = number
  default     = 512
}

variable "frontend_nextjs_image_url" {
  description = "Container image URL for ECS task"
  type        = string
}

variable "frontend_nextjs_tg_arn" {
  description = "Target group ARN for Frontend NextJS ECS Service"
  type        = string
}

variable "frontend_alb_sg_id" {
  description = "Security group ID of frontend ALB to allow access to service"
  type        = string
}

variable "frontend_alb_arn" {
  description = "Frontend ALB ARN for Latency scaling"
  type        = string
}