vpc_cidr       = "10.0.0.0/16"
subnet_a_cidr  = "10.0.1.0/24"
subnet_b_cidr  = "10.0.2.0/24"
container_name = "eitan-nodejs-slim"
ami_name       = "ami-00ddb0e5626798373"
instance_type  = "t2.micro"
user_data_file = "install_docker.tpl"
do_ecs         = true
do_ec2         = true
do_asg         = true
do_lambda      = true

