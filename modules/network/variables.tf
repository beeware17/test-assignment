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
# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/20"
}
variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type        = bool
  default     = true
}
variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "cloudfront_public_ips" {
  description = "Cloudfront public IPs for ALB restriction"
  type        = list(any)
  default     = ["52.93.244.0/24"] # and so on
}

# Subnets
variable "public_subnets_config" {
  description = "Public subnets configuration"
  default = {
    public_a = {
      name                     = "main-public-a"
      cidr_block               = "10.0.1.0/24"
      availability_zone_letter = "a"
      map_public_ip_on_launch  = true
    }
    public_b = {
      name                     = "main-public-b"
      cidr_block               = "10.0.2.0/24"
      availability_zone_letter = "b"
      map_public_ip_on_launch  = true
    }
    public_c = {
      name                     = "main-public-c"
      cidr_block               = "10.0.3.0/24"
      availability_zone_letter = "c"
      map_public_ip_on_launch  = true
    }
  }
}

variable "private_subnets_config" {
  description = "Private subnets configuration"
  type        = any
  default = {
    private_a = {
      name                     = "main-private-a"
      cidr_block               = "10.0.10.0/24"
      availability_zone_letter = "a"
      map_public_ip_on_launch  = false
      nat_key                  = "public_a"
    }
    private_b = {
      name                     = "main-private-b"
      cidr_block               = "10.0.11.0/24"
      availability_zone_letter = "b"
      map_public_ip_on_launch  = false
      nat_key                  = "public_b"
    }
    private_c = {
      name                     = "main-private-c"
      cidr_block               = "10.0.12.0/24"
      availability_zone_letter = "c"
      map_public_ip_on_launch  = false
      nat_key                  = "public_c"
    }
  }
}