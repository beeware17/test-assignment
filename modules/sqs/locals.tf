locals {
  ### Construct necessary names
  short_env_map = {
    development = "dev"
    production  = "prod"
  }
  short_region_map = {
    eu-central-1 = "euc1"
  }
  short_env     = lookup(local.short_env_map, var.environment)
  short_region  = lookup(local.short_region_map, var.aws_region)
  resource_name = "%s-${local.short_region}-${local.short_env}"
  common_tags = {
    environment          = var.environment
    managed_by_terraform = "true"
  }
}