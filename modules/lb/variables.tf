variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "internal" {
  description = "Is the ALB internal?"
  type        = bool
}

variable "target_group_hcheck_port" {
  description = "Target group health check port"
  type        = number
}

variable "target_group_hcheck_path" {
  description = "Target group health check path"
  type        = string
}