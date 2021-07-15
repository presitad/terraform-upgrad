
# Vpc resource
resource "aws_vpc" "myVpc" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "myVpc"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "myVpc"
  }
}


# Subnet (public)
resource "aws_subnet" "public_subnet" {
  count                   = length(var.az_list)
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = "10.20.${10 + count.index}.0/24"
  availability_zone       = var.az_list[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# Subnet (private)
resource "aws_subnet" "private_subnet" {
  count                   = length(var.az_list)
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = "10.20.${20 + count.index}.0/24"
  availability_zone       = var.az_list[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "PrivateSubnet"
  }
}

# Routing table for public subnets
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.myVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route_table_public"
  }
}

resource "aws_route_table_association" "route" {
  count          = length(var.az_list)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.route_table_public.id
}


# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  connectivity_type = "private"
  subnet_id         = element(aws_subnet.private_subnet.*.id, 1)
  depends_on        = [aws_internet_gateway.igw]
}



# Routing table for private subnets
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.myVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "route_table_private"
  }
}

resource "aws_route_table_association" "private_route" {
  count          = length(var.az_list)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.route_table_private.id
}


