# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(local.common_tags, {
    Name = format(local.resource_name, "main-vpc")
  })
}

# All subnets, RTs & associations
resource "aws_subnet" "public" {
  for_each                = var.public_subnets_config
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = "${var.aws_region}${each.value.availability_zone_letter}"
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags = {
    Name = format(local.resource_name, each.value.name)
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = format(local.resource_name, "main-public-rt")
  }
}
resource "aws_route_table_association" "public" {
  for_each       = var.public_subnets_config
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  for_each                = var.private_subnets_config
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = "${var.aws_region}${each.value.availability_zone_letter}"
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags = {
    Name = format(local.resource_name, each.value.name)
  }
}
resource "aws_route_table" "private" {
  for_each = var.private_subnets_config
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.value.nat_key].id
  }

  tags = {
    Name = format(local.resource_name, "main-private-rt")
  }
}
resource "aws_route_table_association" "private" {
  for_each       = var.private_subnets_config
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = format(local.resource_name, "main-igw")
  }
}

# NAT
resource "aws_eip" "nat" {
  for_each = var.public_subnets_config
  domain   = "vpc"
  tags     = merge(local.common_tags, { "Name" : format(local.resource_name, "nat-${each.value.name}") })
}
resource "aws_nat_gateway" "nat" {
  for_each      = var.public_subnets_config
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags = {
    Name = format(local.resource_name, "nat-${each.value.name}")
  }
}