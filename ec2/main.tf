provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_ecr_repository" "nodejs-ecr" {
  name = var.container_name
}


resource "aws_security_group" "ubuntu" {
  name        = "ubuntu-security-group"
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
    cidr_blocks = ["0.0.0.0/0"]
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

 #resource "aws_network_interface" "web-server-nic" {
 #  subnet_id       = var.subnet_id
   #private_ips     = ["10.0.1.50"]
 #  security_groups = [aws_security_group.ubuntu.id]
 #}

data "template_file" "install_docker" {
template = file("${path.module}/install_docker.tpl")
vars = {
  container_name           = data.aws_ecr_repository.nodejs-ecr.repository_url
 }
}

resource "aws_iam_role" "instance_ecr_role" {
  name = "instance_ecr_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF  
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryFullAccess" {
  role       = aws_iam_role.instance_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_instance_profile" "instance_ecr_role_instance" {
  name  = "instance_ecr_role"
  role = aws_iam_role.instance_ecr_role.name
}

resource "aws_instance" "nodejs-ubuntu" {
  key_name      = "earnix"
  ami           = var.ami_name
  subnet_id     = var.subnet_id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.instance_ecr_role_instance.name
  user_data = data.template_file.install_docker.rendered
  associate_public_ip_address = true
  #network_interface {
  #  device_index         = 0
  #  network_interface_id = aws_network_interface.web-server-nic.id
  #}

  tags = {
    Name = "earnix"
  }

  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("earnix_key.pem")
    host        = self.public_ip
  }

}


output "nodejs_public_ip" {
 value = [aws_instance.nodejs-ubuntu.*.public_ip]
}

output "aws_instance_ip" {
  value = aws_instance.nodejs-ubuntu.private_ip
}
