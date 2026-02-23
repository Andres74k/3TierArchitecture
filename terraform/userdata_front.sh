#!/bin/bash

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
http://169.254.169.254/latest/meta-data/placement/availability-zone)

echo "AZ=$AZ" >> /etc/environment

echo "APP_ALB_DNS=${app_alb_dns}" >> /etc/environment

export AZ=$AZ
export APP_ALB_DNS=${app_alb_dns}

yum install -y git nodejs
cd /home/ec2-user

git clone "${repo_link}"
REPO_NAME=$(basename "${repo_link}" .git)
sudo chown -R ec2-user:ec2-user $REPO_NAME
cd "$REPO_NAME"
cd frontend

npm install
node server.js &
