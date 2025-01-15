# This file creates a VPC, public subnets, and an internet gateway.

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc_${replace(var.resource_prefix, "-", "_")}"
  }
}

resource "aws_subnet" "public" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.this.id
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  cidr_block              = local.subnet_cidr_ranges[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = replace("public_subnet_${count.index}_${var.resource_prefix}", "-", "_")
    az   = data.aws_availability_zones.available_azs.names[count.index]
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "igw_${var.resource_prefix}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "igw_route_table_${var.resource_prefix}"
  }
}

resource "aws_route_table_association" "public_subnet_routes" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
