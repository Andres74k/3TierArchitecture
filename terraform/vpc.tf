resource "aws_vpc" "main" {
  cidr_block       = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support =  true
  tags = {
    Name = "${var.prefix}vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name ="${var.prefix}internet_gateway"
  }
}