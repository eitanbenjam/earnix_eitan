variable vpc_cidr {
    description = "vpc cidr"
    default = "10.0.0.0/16"
}

variable subnet_a_cidr {
    description = "subnet a cidr"
    default = "10.0.1.0/24"
}

variable subnet_b_cidr {
    description = "subnet b cidr"
    default = "10.0.2.0/24"
}

variable "container_name" {
  type        = string
  default     = "eitan-nodejs-slim"
}

