resource "aws_security_group" "asg" {
  name        = "asg-security-group"
  description = "Allow 8000 and SSH traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [ var.lb_sec_group ]
  } 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "earnix"
  }
}

data "template_file" "install_docker" {
template = file("${path.module}/../user_data_files/${var.user_data_file}")
vars = {
  container_name           = var.ecr_repository
 }
}

resource "aws_launch_configuration" "web" {
  name_prefix = var.name_prefix

  image_id = var.ami_name # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = var.instance_type
  key_name = var.key_name

  security_groups = [ aws_security_group.asg.id ]
  associate_public_ip_address = true

  user_data = data.template_file.install_docker.rendered

  lifecycle {
    create_before_destroy = true
  }
  
}
resource "aws_autoscaling_group" "web" {
  name = "${aws_launch_configuration.web.name}-asg"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 4
  
  health_check_type    = "ELB"
  load_balancers = [
    var.alb_id
  ]

  launch_configuration = aws_launch_configuration.web.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = var.subnets

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }

}
