locals {
  public_subnets = {
    public-subnet-a = {
      cidr = "10.0.1.0/24"
      az   = "us-west-2a"
    }
    public-subnet-b = {
      cidr = "10.0.2.0/24"
      az   = "us-west-2b"
    }
  }

  private_subnets = {
    private-subnet-a = {
      cidr = "10.0.3.0/24"
      az   = "us-west-2a"
    }
    private-subnet-b = {
      cidr = "10.0.4.0/24"
      az   = "us-west-2b"
    }
  }

  private_to_nat = {
    private-subnet-a = "public-subnet-a"
    private-subnet-b = "public-subnet-b"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { 
    Name = var.vpc_name 
  }
}


# Subnets

# Public Subnet
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = { 
    Name = each.key 
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = { 
    Name = each.key 
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { 
    Name = "${var.vpc_name}-igw" 
  }
}


# Multi-AZ NAT Gateway
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = { Name = "nat-eip-${each.key}" }
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id

  tags = { 
    Name = "nat-gw-${each.key}" 
  }
}

# Route Tables

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { 
    Name = "public-rt" 
  }
}

# Private Route Tables
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.main.id

  tags = { 
    Name = "${each.key}-rt" 
  }
}

resource "aws_route" "private_nat_route" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.nat[
    local.private_to_nat[each.key]
  ].id
}

# Route Table Associations

# Public Route Table Association
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table Association
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "ALB-SG"
  description = "Allows HTTP traffic from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB-SG"
  }
}

# ECS Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "ECS-SG"
  description = "Allows HTTP traffic from the ALB-SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS-SG"
  }
}

# EFS Security Group
resource "aws_security_group" "efs_sg" {
  name        = "EFS-SG"
  description = "Allows NFS traffic from ECS-SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS-SG"
  }
}
