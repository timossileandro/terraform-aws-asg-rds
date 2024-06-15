###   Security Groups   ###
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${local.env}-${local.platform}-${local.app}-sg-01"
  description = "Security group to be used by Load Balancer."
  vpc_id      = aws_vpc.app.id

  ingress {
    description      = "Allow http request from anywhere"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow https request from anywhere"
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}


# App Security Group
resource "aws_security_group" "app" {
  name        = "${local.env}-${local.platform}-${local.app}-sg-02"
  description = "Security group to be used by App Web Server."
  vpc_id      = aws_vpc.app.id

  ingress {
    description     = "Allow http request from Load Balancer"
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Allow Bastion access to Web Server intances
resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = aws_vpc.bastion.cidr_block
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}


# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name        = "${local.env}-${local.platform}-${local.app}-sg-03"
  description = "Security group to be used by Bastion Host"
  vpc_id      = aws_vpc.bastion.id

  ingress {
    description      = "Allow SSH request from anywhere"
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}


# RDS Aurora
resource "aws_security_group" "rds" {
  name        = "${local.env}-${local.platform}-${local.app}-sg-04"
  description = "Security group to be used by RDS"
  vpc_id      = aws_vpc.app.id

  ingress {
    description     = "Allow DB port request from anywhere"
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.app.id]
  }

  tags = local.tags
}

resource "aws_db_subnet_group" "rds" {
  name       = "${local.env}-${local.platform}-${local.app}-rds-subnet-group-01"
  subnet_ids = [aws_subnet.db_az_a.id, aws_subnet.db_az_b.id]
}