variable "subnet_id" {
    type = string
}

variable "ami_name" {
    type    = string    
}

variable "instance_type" {
    type  = string    
}

variable "container_name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "lb_sec_group" {
    type = string
}

variable "user_data_file" {
    type = string
}

variable "ecr_repository" {
    type = string
}
