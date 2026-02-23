# ---- public ALB SECURITY GROUP -----

resource "aws_security_group" "web_alb" {
  provider = aws
  name = "web_alb"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_in" {
  security_group_id = aws_security_group.web_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_web_http" {
  security_group_id = aws_security_group.web_alb.id
  referenced_security_group_id = aws_security_group.web_ec2.id
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
}

#------- private alb security group --------

resource "aws_security_group" "app_alb" {
  provider = aws
  name = "app_alb"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_alb_web_in" {
  security_group_id = aws_security_group.app_alb.id
  referenced_security_group_id = aws_security_group.web_ec2.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_alb_to_web_http" {
  security_group_id = aws_security_group.app_alb.id
  referenced_security_group_id = aws_security_group.app_ec2.id
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
}


#----WEB EC2 SECURITY GROUP-----

resource "aws_security_group" "web_ec2" {
  provider = aws
  name = "web_ec2_sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_from_alb_http" {
  security_group_id = aws_security_group.web_ec2.id
  referenced_security_group_id = aws_security_group.web_alb.id
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_all_outbound" {
  security_group_id = aws_security_group.web_ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#----APP EC2 SECURITY GROUP-----

resource "aws_security_group" "app_ec2" {
  provider = aws
  name = "app_ec2_sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb_http" {
  security_group_id = aws_security_group.app_ec2.id
  referenced_security_group_id = aws_security_group.app_alb.id
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_outbound" {
  security_group_id = aws_security_group.app_ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

#--------------database---------

resource "aws_security_group" "rds" {
  name = "rds-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "backend_to_rds" {
  type = "ingress"

  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id = aws_security_group.rds.id
  source_security_group_id = aws_security_group.app_ec2.id
}