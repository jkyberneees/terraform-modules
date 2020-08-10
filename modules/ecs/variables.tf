variable "logs_region" {
  description = "ECS logs configuration region"
  type        = string
}

variable "namespace" {
  description = "Application namespace"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "alb_sg_id" {
  description = "ALB Security Group id"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ALB Target Group ARN"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "desired_tasks_count" {
  description = "Desired tasks count"
  type        = number
}

variable "task_cpu" {
  description = "Allocated task CPU"
  type        = string
}

variable "task_memory" {
  description = "Allocated task RAM"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "subnet_ids" {
  description = "Comma separated subnet ids"
  type        = string
}

variable "container_image_tag" {
  description = "ECS container image tag"
  type        = string
}
