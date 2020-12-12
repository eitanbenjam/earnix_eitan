# earnix_eitan
# repository goal
Create one endpoint with 3 services
1. /ecs service that will forward http request to ecs container
2. /ec2 service that will forward http request to ec2 that run docker container
3. /lambda service that will trigger lambda and return json with the current time (UTC)
## Installation

in order to run the earnix_eitan server u need to perform the following steps:
1. clone repository :
```
git clone git clone https://github.com/eitanbenjam/earnix_eitan.git
```
2. after repository cloned to your filesystem, we need to start docker-regitry container
```
cd earnix_eitan/main
terraform init # will download all needed dependencies
terraform plan # will plan the action needed and show what will be perform
terraform apply -auto-approve # will start deploy
```
terraform will start deploying all the component
at the end you will see load-balancer nds address
```
Outputs:
load_balancer_url = "earnixAlb-1171883708.us-east-1.elb.amazonaws.com"
```
to test:
open browser and browse to:
1. http://<loadbalancer-dns>/lambda 
   you should get json that specify the currect time
2. http://<loadbalancer-dns>/ecs
   you should get response from containr that run on ecs :Hello Earnix from ECS
3. http://<loadbalancer-dns>/ec2
   you should get response from containr that run on ec2 instance  :Hello Earnix from EC2

## ECR
the docker image should already exist in ECR , it you dont have ECR there is terraform deployment to start it under ecr folder 
