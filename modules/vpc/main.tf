locals {
  subnets = {
    "${var.region}a" = var.subnet1
    "${var.region}b" = var.subnet2
    "${var.region}c" = var.subnet3
  }
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-vpc"
    App  = var.app_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.app_name}-igw"
    App  = var.app_name
  }
}

resource "aws_subnet" "this" {
  count      = length(local.subnets)
  cidr_block = element(values(local.subnets), count.index)
  vpc_id     = aws_vpc.this.id

  map_public_ip_on_launch = true
  availability_zone       = element(keys(local.subnets), count.index)

  tags = {
    Name = "${var.app_name}-subnet-${element(keys(local.subnets), count.index)}"
    App  = var.app_name
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.app_name}-routetable"
    App  = var.app_name
  }
}

resource "aws_route" "this" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "this" {
  count          = length(local.subnets)
  route_table_id = aws_route_table.this.id
  subnet_id      = element(aws_subnet.this.*.id, count.index)
}