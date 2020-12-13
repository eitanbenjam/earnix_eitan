variable "name_prefix" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "key_name" {
    default = "no_name"
}

variable "ami_name" {
    type = string
}

variable "user_data_file" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "lb_sec_group" {
    type = string
}


variable "alb_id" {
    type = string
}

variable "subnets" {
    type = list
}

variable "ecr_repository" {
    type = string
}

