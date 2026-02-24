output "public_alb_dns" {
  description = "DNS name of the public Application Load Balancer"
  value       = aws_alb.public.dns_name
}

output "private_alb_dns" {
  description = "DNS name of the internal Application Load Balancer"
  value       = aws_alb.private.dns_name
}

output "rds_endpoint" {
  description = "PostgreSQL RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "PostgreSQL RDS address (without port)"
  value       = aws_db_instance.main.address
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}