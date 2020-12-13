# Creating Load Balancer
resource "aws_alb" "application_load_balancer" {
  name               = var.lb_name
  load_balancer_type = "application"
  subnets = var.subnets  
  security_groups = [aws_security_group.load_balancer_security_group.id]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id        = var.vpc_id 
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
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


# Creating  EC2 security group
resource "aws_lb_target_group" "ec2_target_group" {
  name        = "ec2-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200,301,302"
    path = "/test"
  }
  depends_on = [aws_alb.application_load_balancer] 
}

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.ec2_target_group.arn
  target_id        = var.aws_instance
  port             = 8000
}
# Creating  ECS target group

resource "aws_lb_target_group" "ecs_target_group" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200,301,302"
    path = "/test"
  }
  depends_on = [aws_alb.application_load_balancer] 
}

# Creating  ASG target group

resource "aws_lb_target_group" "asg_target_group" {
  name        = "asg-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200,301,302"
    path = "/test"
  }
  depends_on = [aws_alb.application_load_balancer] 
}


# Creating  Lambda target group
resource "aws_lb_target_group" "lambda_target_group" {
  name        = "lambda-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "lambda"
  vpc_id      = var.vpc_id  
  depends_on = [aws_alb.application_load_balancer] 
}

# Creating load balancer listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Earnix - Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "ecs_forword" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 95

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.id
  }

  condition {
    path_pattern {
      values = ["/ecs"]
    }
  }    
}

resource "aws_lb_listener_rule" "asg_forword" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 91

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_target_group.id
  }

  condition {
    path_pattern {
      values = ["/asg"]
    }
  }    
}

resource "aws_lb_listener_rule" "ec2_forword" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 94

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_target_group.id
  }

  condition {
    path_pattern {
      values = ["/ec2"]
    }
  }    
}

resource "aws_lb_listener_rule" "lambda_forword" {
  count = var.lambda_name != "none" ? 1 : 0
  listener_arn = aws_lb_listener.listener.arn
  priority     = 96

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_target_group.id
  }

  condition {
    path_pattern {
      values = ["/lambda"]
    }
  } 
}

resource aws_lambda_permission alb {
  count = var.lambda_name != "none" ? 1 : 0
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "elasticloadbalancing.amazonaws.com"
  #qualifier     = aws_lambda_alias.live.name
  source_arn    = aws_lb_target_group.lambda_target_group.arn
}


resource "aws_lb_target_group_attachment" "lambda_forword_attach" {
  count = var.lambda_name != "none" ? 1 : 0
  target_group_arn = aws_lb_target_group.lambda_target_group.arn
  target_id        = var.lambda_arn
  depends_on       = [aws_lambda_permission.alb]
}

# OUTPUTS
output "alb_id" {
  value = aws_alb.application_load_balancer.id
}

output "dns_name" {
  value = aws_alb.application_load_balancer.dns_name
}


output "ecs_target_group" {
  value = aws_lb_target_group.ecs_target_group.id
}

output "sec_group" {
  value = aws_security_group.load_balancer_security_group.id
}
