output "alb_address" {
  value       = module.alb.alb_address
  description = "Application ALB address"
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = module.ecs.ecr_repository_url
}