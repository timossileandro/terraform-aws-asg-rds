# For Bastion Host
# Route and Internet Gateway to allow intenet access to the Bastion host
resource "aws_internet_gateway" "bastion" {
  vpc_id = aws_vpc.bastion.id

  tags = local.tags
}

data "aws_route_table" "bastion" {
  vpc_id = aws_vpc.bastion.id
}

resource "aws_route" "bastion" {
  route_table_id         = data.aws_route_table.bastion.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bastion.id
}


# Route and Internet Gateway to allow intenet access to the ALB
resource "aws_internet_gateway" "alb" {
  vpc_id = aws_vpc.app.id

  tags = local.tags
}


# Route table for public subnet to connect to Internet gateway
resource "aws_route_table" "alb" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.alb.id
  }
}


# Associate the route table with public subnets
resource "aws_route_table_association" "rta_sub_1" {
  subnet_id      = aws_subnet.public_az_a.id
  route_table_id = aws_route_table.alb.id
}

resource "aws_route_table_association" "rta_sub_2" {
  subnet_id      = aws_subnet.public_az_b.id
  route_table_id = aws_route_table.alb.id
}


# ALB Configuration
resource "aws_lb" "app" {
  name               = "${local.env}-${local.platform}-${local.app}-alb-01"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_az_a.id, aws_subnet.public_az_b.id]

  tags = local.tags
}

resource "aws_lb_target_group" "app" {
  name     = "${local.env}-${local.platform}-${local.app}-alb-tg-01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}


# Elastic IP for NAT gateway
resource "aws_eip" "app" {
  depends_on = [aws_internet_gateway.alb]
  domain     = "vpc"
  tags       = local.tags
}

# NAT gateway for private subnets
resource "aws_nat_gateway" "app" {
  allocation_id = aws_eip.app.id
  subnet_id     = aws_subnet.public_az_a.id

  tags = local.tags

  depends_on = [aws_internet_gateway.alb]
}

# Route table for connecting to NAT
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app.id
  }
}