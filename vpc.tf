###   VPC and Subnets   ###
resource "aws_vpc" "app" {
  cidr_block = "172.50.0.0/16"

  tags = local.tags
}

resource "aws_vpc" "bastion" {
  cidr_block = "172.100.0.0/24"

  tags = local.tags
}


# Public Subnet
resource "aws_subnet" "public_az_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "172.50.0.0/27"
  availability_zone = "${var.aws_region}a"

  tags = local.tags
}

resource "aws_subnet" "public_az_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "172.50.0.32/27"
  availability_zone = "${var.aws_region}b"

  tags = local.tags
}


# Subnets App
resource "aws_subnet" "app_az_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "172.50.10.0/27"
  availability_zone = "${var.aws_region}a"

  tags = local.tags
}

resource "aws_subnet" "app_az_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "172.50.10.32/27"
  availability_zone = "${var.aws_region}b"

  tags = local.tags
}


# Subnets DB
resource "aws_subnet" "db_az_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "172.50.10.64/27"
  availability_zone = "${var.aws_region}a"

  tags = local.tags
}

resource "aws_subnet" "db_az_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "172.50.10.96/27"
  availability_zone = "${var.aws_region}b"

  tags = local.tags
}

resource "aws_db_subnet_group" "db" {
  name       = "${local.env}-${local.platform}-${local.app}-subnet-group-01"
  subnet_ids = [aws_subnet.db_az_a.id, aws_subnet.db_az_b.id]

  tags = local.tags
}


# Subnet Bastion Host
resource "aws_subnet" "bastion" {
  vpc_id            = aws_vpc.bastion.id
  cidr_block        = "172.100.0.0/27"
  availability_zone = "${var.aws_region}c"

  tags = local.tags
}