
resource "aws_iam_role" "ecs_iam" {
  name               = var.ecs_iam_name
  assume_role_policy = file("${path.module}/policy.json")
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecs_iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonECS_FullAccess" {
  role       = aws_iam_role.ecs_iam.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

 


resource "aws_ecs_cluster" "eitan_ecs_cluster" {
  name = var.ecs_cluster_name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

data "aws_ecr_repository" "nodejs-ecr" {
  name = var.container_name
}

resource "aws_security_group" "ecs_security_group" {
  vpc_id        = var.vpc_id 
  ingress {
    from_port   = 8000 # Allowing traffic in from port 80
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}


resource "aws_ecs_service" "http" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.eitan_ecs_cluster.id
  task_definition = aws_ecs_task_definition.http.arn
  desired_count   = 1
  #iam_role        = aws_iam_role.ecs_iam.arn
  depends_on      = [aws_iam_role.ecs_iam]


  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight = 100    
  }
  
  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = [aws_security_group.ecs_security_group.id] # Setting the security group
  }

  load_balancer {
    target_group_arn = var.ecs_target_group
    container_name   = aws_ecs_task_definition.http.family
    container_port   = 8000
  }

  
}

resource "aws_ecs_task_definition" "http" {
  family                = "eitan-nodejs-slim"
  container_definitions = <<DEFINITION
 [
  {
    "name": "eitan-nodejs-slim",
    "image": "${data.aws_ecr_repository.nodejs-ecr.repository_url}",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 8000
      }
    ]
  }
]
DEFINITION

  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecs_iam.arn
}

