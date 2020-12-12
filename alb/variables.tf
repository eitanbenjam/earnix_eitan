variable "subnets" {
  type        = list  
  description = "alb subnets"
}

variable "lb_name" {
    type    = string
}

variable "vpc_id" {
    type    = string
}

variable "lambda_arn" {
    type    = string
}

variable "lambda_name" {
    type    = string
}