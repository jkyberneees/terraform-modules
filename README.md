# terraform-modules
Generic Terraform Modules

> `vpc`, `ecs` and `lb` modules were inspired by https://snow-dev.com/posts/ecs-cd-with-codepipeline-in-terraform.html

## Full example
By running this example you will be creating the following resources:
- A VPC with 3 public subnets. 
- An Application Load Balancer with 2 target groups for blue/green deployments. 
- An ECR repository, ECS Fargate cluster with service and task definitions. 

> Ultimatelly, your docker based application is deployed and accessible under the ALB public DNS address. Created resources are properly tagged, and security policies are applied using Security Groups.  

```terraform
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
```
> Accessing the modules remotely: `git::https://github.com/jkyberneees/terraform-modules.git//modules/vpc`

The `terraform.tfvars.json` file:
```json
{
    "region": "us-east-1",
    "app_name": "myapp",
    "namespace": "myns",
    "container_port": 8080,
    "container_image_tag": "1.0.1",
    "ecs_desired_tasks_count": 1,
    "ecs_task_memory": "512",
    "ecs_task_cpu": "256",
    "alb_internal": false,
    "target_group_hcheck_path": "/api/health/status"
}
```


## TODOs
- [ ] Add modules documentation