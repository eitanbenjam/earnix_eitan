#!/bin/bash
export HOME=/root/
apt update
apt-get install docker.io -y
apt  install awscli -y
eval $(aws ecr get-login --region us-east-1 | sed "s|-e none https://||")
docker run --restart always -d -p 8000:8000 ${container_name}
