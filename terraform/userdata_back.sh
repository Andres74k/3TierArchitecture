#!/bin/bash
echo "DB_HOST=${db_instance}" >> /etc/environment
echo "DB_USER=${db_username}" >> /etc/environment
echo "DB_PASS=${db_password}" >> /etc/environment
echo "DB_NAME=${db_name}" >> /etc/environment
source /etc/environment

yum update -y
yum install -y nodejs git
sudo yum install -y postgresql nmap-ncat  # ensure nc is installed

cd /home/ec2-user
git clone "${repo_link}"

REPO_NAME=$(basename "${repo_link}" .git)
sudo chown -R ec2-user:ec2-user "$REPO_NAME"
cd "$REPO_NAME/backend"

npm install
npm install pg
npm run build

# Wait for DB to be reachable before seeding
echo "Waiting for DB to be ready..."
while ! nc -zv "$DB_HOST" 5432 >/dev/null 2>&1; do
  echo "DB not ready yet, waiting 5s..."
  sleep 5
done

echo "DB is up, running seed..."
npm run seed

echo "Starting NestJS..."
npm run start:prod &
