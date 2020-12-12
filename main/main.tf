provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_ecr_repository" "nodejs-ecr" {
  name = var.container_name
}

# Creating earnix vpc
module "test_vpc" {
  source   = "../vpc"
  cidr = var.vpc_cidr
  tag_values = {
    "name" = "earnix vpc"
    "perpose" = "Earnix Task"
  }
}

# Creating subnet A
resource "aws_subnet" "public_us_east_1a" {
  vpc_id            = module.test_vpc.eitan_vpc_id
  cidr_block        = var.subnet_a_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet us-east-1a"
  }
}

# Creating subnet B
resource "aws_subnet" "public_us_east_1b" {
  vpc_id            = module.test_vpc.eitan_vpc_id
  cidr_block        = var.subnet_b_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "Subnet us-east-1b"
  }
}

# Creating Interent Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = module.test_vpc.eitan_vpc_id

}

resource "aws_route_table" "prod-route-table" {
  vpc_id = module.test_vpc.eitan_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
 }

 resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_us_east_1a.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_us_east_1b.id
  route_table_id = aws_route_table.prod-route-table.id
}


# Creating ECS
module "ecs" {
  source           = "../ecs"
  subnets          = [aws_subnet.public_us_east_1a.id, aws_subnet.public_us_east_1b.id]
  alb_id           = module.alb.alb_id
  ecs_target_group = module.alb.ecs_target_group
  vpc_id           = module.test_vpc.eitan_vpc_id
  lb_sec_group = module.alb.sec_group
  
}

# Creating Lambda
module "lambda" {
    source = "../lambda"    
}

# Createing EC2
module "ec2" {
    source = "../ec2"
    subnet_id       = aws_subnet.public_us_east_1b.id
    vpc_id      = module.test_vpc.eitan_vpc_id
    container_name  = var.container_name
    lb_sec_group = module.alb.sec_group
}

# Creating LoadBalancer
module "alb" {
    source      = "../alb"   
    subnets     = [aws_subnet.public_us_east_1a.id, aws_subnet.public_us_east_1b.id]
    lb_name     = "earnixAlb"
    vpc_id      = module.test_vpc.eitan_vpc_id   
    lambda_arn  = module.lambda.lambda_arn  
    lambda_name = module.lambda.lambda_name
    aws_instance = module.ec2.aws_instance_ip
}

output "load_balancer_url" {
    value = module.alb.dns_name
}



