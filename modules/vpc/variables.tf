variable "region" {
  description = "AWS Region"
  type        = string
}

variable "subnet1" {
  description = "Subnet 1 - CIDR with 251 available IPs"
  type        = string
  default     = "172.10.1.0/24"
}

variable "subnet2" {
  description = "Subnet 2 - CIDR with 251 available IPs"
  type        = string
  default     = "172.10.2.0/24"
}

variable "subnet3" {
  description = "Subnet 3 - CIDR with 251 available IPs"
  type        = string
  default     = "172.10.3.0/24"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "172.10.0.0/16"
}

variable "app_name" {
  description = "Application name"
  type        = string
}


