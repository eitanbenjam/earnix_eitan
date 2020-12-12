variable "subnet_id" {
    type = string
}

variable "ami_name" {
    default = "ami-00ddb0e5626798373"
}

variable "instance_type" {
    default = "t2.micro"
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
