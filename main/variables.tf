variable vpc_cidr {
    description = "vpc cidr"    
}

variable subnet_a_cidr {
    description = "subnet a cidr"    
}

variable subnet_b_cidr {
    description = "subnet b cidr"
}

variable "container_name" {
  type        = string
}

variable "ami_name" {
    type     = string
}

variable "instance_type" {
    type = string
}

variable "do_ecs" {
    type = bool
}

variable "do_ec2" {
    type = bool
}

variable "do_asg" {
    type = bool
}

variable "do_lambda" {
    type = bool
}

variable "user_data_file" {
    type = string
}
