
variable "ecs_iam_name" {
  type        = string
  default     = "ecs_iam"
  description = "Name of IAM for ECS"
}

variable "ecs_cluster_name" {
  type        = string
  default     = "earnix_ecs_cluster"
  description = "Name of ECS cluster"
}

variable "ecs_service_name" {
  type        = string
  default     = "earnix_ecs_service"
  description = "Name of ECS service"
}

variable "subnets" {
  type        = list  
  description = "ecs subnets"
}

variable "container_name" {
  type        = string
  default     = "eitan-nodejs-slim"
}

variable "alb_id" {
  type        = string
}

variable "ecs_target_group" {
  type        = string
}

variable "vpc_id" {
  type        = string
}