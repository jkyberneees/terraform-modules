variable "region" {
  description = "AWS Region"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "namespace" {
  description = "Application namespace"
  type        = string
}

variable "container_port" {
  description = "ECS container port"
  type        = number
}

variable "container_image_tag" {
  description = "ECS container image tag"
  type        = string
}

variable "ecs_desired_tasks_count" {
  description = "ECS desired tasks count"
  type        = number
}

variable "ecs_task_memory" {
  description = "ECS task memory allocation"
  type        = string
}

variable "ecs_task_cpu" {
  description = "ECS task CPU allocation"
  type        = string
}

variable "alb_internal" {
  description = "Should ALB be internal?"
  type        = bool
}

variable "target_group_hcheck_path" {
  description = "ALB target group health check path"
  type        = string
}
