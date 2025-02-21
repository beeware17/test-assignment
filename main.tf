module "network" {
  source      = "./modules/network"
  aws_region  = var.aws_region
  environment = var.environment
}

module "sqs" {
  source      = "./modules/sqs"
  aws_region  = var.aws_region
  environment = var.environment
}

module "ecs" {
  source      = "./modules/ecs"
  aws_region  = var.aws_region
  environment = var.environment

  vpc_id              = module.network.vpc_id
  private_subnets_ids = module.network.private_subnets_ids

  backend_alb_sg_id      = module.network.backend_sg_id
  backend_grpc_image_url = "<SOME APP IMAGE FROM ECR>"
  backend_grpc_tg_arn    = module.network.backend_grpc_tg_arn
  backend_alb_arn        = module.network.backend_alb_arn
  backend_sqs_image_url  = "<SOME APP IMAGE FROM ECR>"
  sqs_arn                = module.sqs.main_sqs_arn
  sqs_address            = module.sqs.main_sqs_url

  frontend_alb_sg_id        = module.network.frontend_sg_id
  frontend_nextjs_image_url = "<SOME APP IMAGE FROM ECR>"
  frontend_nextjs_tg_arn    = module.network.frontend_tg_arn
  frontend_alb_arn          = module.network.frontend_alb_arn

}