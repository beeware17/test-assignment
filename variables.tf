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