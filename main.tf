provider "aws" {
  region  = var.region
  version = "3.0.0"
}

module "vpc" {
  source   = "./modules/vpc"
  region   = var.region
  app_name = var.app_name
}

module "alb" {
  source                   = "./modules/lb"
  vpc_id                   = module.vpc.vpc_id
  app_name                 = var.app_name
  target_group_hcheck_port = var.container_port
  target_group_hcheck_path = var.target_group_hcheck_path
  internal                 = var.alb_internal
}

module "ecs" {
  source               = "./modules/ecs"
  logs_region          = var.region
  app_name             = var.app_name
  namespace            = var.namespace
  region               = var.region
  container_port       = var.container_port
  container_image_tag  = var.container_image_tag
  desired_tasks_count  = var.ecs_desired_tasks_count
  task_memory          = var.ecs_task_memory
  task_cpu             = var.ecs_task_cpu
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.subnet_ids
  alb_sg_id            = module.alb.alb_sg_id
  alb_target_group_arn = module.alb.alb_target_group_arn
}