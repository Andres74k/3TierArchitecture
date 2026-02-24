#!/bin/sh

echo "Waiting for database..."
sleep 5

echo "Running seed..."
npm run seed

echo "Starting NestJS..."
npm run start:prod