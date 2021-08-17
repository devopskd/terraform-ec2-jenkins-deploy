# VPC ##
resource "aws_vpc" "terraform-vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy

  tags = {
    Name = var.tags
  }
}

# Internet Gateway ##
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = "terraform-igw"
  }
}

# subnet ##
resource "aws_subnet" "terraform-subnet_1" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = "172.16.10.0/24"
  #   availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "terraform-subnet_1"
  }
}

# Route Table ##
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "terraform-rtb"
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.terraform-subnet_1.id
  route_table_id = aws_route_table.rtb_public.id
}