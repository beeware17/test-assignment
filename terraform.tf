terraform {
  required_version = "~> 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.66.0"
    }
  }
  backend "s3" {
    bucket  = "test-assignment-23423"
    key     = "infra.tfstate"
    region  = "eu-central-1"
    profile = "aws-free-tier"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "aws-free-tier"
}