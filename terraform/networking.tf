
resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone[0]
  tags = {
    Name ="${var.prefix}web1_sub"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.123.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone[1]
  tags = {
    Name ="${var.prefix}web2_sub"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "web_rt_association" {
  for_each = {
    web_a = aws_subnet.public_a.id
    web_b = aws_subnet.public_b.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

#---------------------------------------

resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.123.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = var.availability_zone[0]
  tags = {
    Name ="${var.prefix}app1_sub"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.123.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = var.availability_zone[1]
  tags = {
    Name ="${var.prefix}app2_sub"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "app_rt_association" {
  for_each = {
    app_a = aws_subnet.private_a.id
    app_b = aws_subnet.private_b.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

