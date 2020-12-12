resource "aws_vpc" "eitan_vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

 tags  = var.tag_values
    
  
}

output "eitan_vpc_id" {
  value = aws_vpc.eitan_vpc.id
}