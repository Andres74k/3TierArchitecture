#__________general
resource "aws_ecs_cluster" "main" {
  name = "3tier-cluster"
}

data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [
    aws_ecs_capacity_provider.frontend_asg.name,
    aws_ecs_capacity_provider.backend_asg.name
  ]
}

#_________frontend

resource "aws_launch_template" "frontend_ecs" {
  name_prefix   = "ecs-nodes-"
  image_id      = data.aws_ami.ecs.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.web_ec2.id
    ]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
EOF
  )
}


resource "aws_autoscaling_group" "frontend_ecs" {
  desired_capacity = 2
  max_size         = 2
  min_size         = 1

  launch_template {
    id      = aws_launch_template.frontend_ecs.id
    version = "$Latest"
  }

  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_ecs_capacity_provider" "frontend_asg" {
  name = "frontend-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.frontend_ecs.arn
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = "100605091414.dkr.ecr.us-east-1.amazonaws.com/3tier_frontend:amd64"

      memory = 256
      cpu    = 128

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        { name = "APP_ALB_DNS", value = aws_alb.private.dns_name }
      ]
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  network_configuration {
    subnets = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]

    security_groups = [
      aws_security_group.web_ec2.id
    ]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.frontend_asg.name
    weight            = 1
  }
}

#____backend

resource "aws_launch_template" "backend_ecs" {
  name_prefix   = "ecs-nodes-"
  image_id      = data.aws_ami.ecs.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      aws_security_group.app_ec2.id
    ]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
EOF
  )
}


resource "aws_autoscaling_group" "backend_ecs" {
  desired_capacity = 2
  max_size         = 2
  min_size         = 1

  launch_template {
    id      = aws_launch_template.backend_ecs.id
    version = "$Latest"
  }

  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_ecs_capacity_provider" "backend_asg" {
  name = "backend_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.backend_ecs.arn
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "100605091414.dkr.ecr.us-east-1.amazonaws.com/3tier_backend:amd64"

      memory = 256
      cpu    = 128

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        { name = "DB_HOST", value = aws_db_instance.main.address },
        { name = "DB_USER", value = var.db_username },
        { name = "DB_PASS", value = var.db_password },
        { name = "DB_NAME", value = var.db_name }
      ]
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "backend"
    container_port   = 3000
  }

  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_groups = [
      aws_security_group.app_ec2.id
    ]

    assign_public_ip = false
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.backend_asg.name
    weight            = 1
  }
}