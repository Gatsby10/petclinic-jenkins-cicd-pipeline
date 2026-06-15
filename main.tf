locals {
  name = "petclinic"
}

#Creating a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
    tags = {
        Name = "${local.name}-vpc"
    }
}

# Creating Public subnet 1
resource "aws_subnet" "pubsub-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pubsub1
  availability_zone = "eu-west-3a"
    tags = {
        Name = "${local.name}-public-subnet-1"
    }
}

# Creating Public subnet 2
resource "aws_subnet" "pubsub-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pubsub2
  availability_zone = "eu-west-3b"
    tags = {
        Name = "${local.name}-public-subnet-2"
    }
}

# Creating Private subnet 1
resource "aws_subnet" "prisub-1" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = var.prisub1
    availability_zone = "eu-west-3a"
        tags = {
            Name = "${local.name}-private-subnet-1"
        }
    }

# Creating Private subnet 2
resource "aws_subnet" "prisub-2" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = var.prisub2
    availability_zone = "eu-west-3b"
        tags = {
            Name = "${local.name}-private-subnet-2"
        }
    }

#creating internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${local.name}-internet-gateway"
    }
}

#creating elastic ip for nat gateway
resource "aws_eip" "eip" {
    domain = "vpc"
    tags = {
        Name = "${local.name}-elastic-ip"
    }
}

#creating nat gateway
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.eip.id
    subnet_id     = aws_subnet.pubsub-1.id
    tags = {
        Name = "${local.name}-nat-gateway"
    }
}

#Creating Public Route Table
resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = var.all_cidr_blocks
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${local.name}-public-route-table"
    }
}

# Creating Private Route Table
resource "aws_route_table" "private-route-table" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = var.all_cidr_blocks
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = {
        Name = "${local.name}-private-route-table"
    }
}

# Public subnet 1 route table association
resource "aws_route_table_association" "pubsub-1-association" {
    subnet_id = aws_subnet.pubsub-1.id
    route_table_id = aws_route_table.public-route-table.id
}


# Public subnet 2 route table association
resource "aws_route_table_association" "pubsub-2-association" {
    subnet_id = aws_subnet.pubsub-2.id
    route_table_id = aws_route_table.public-route-table.id
}

# Private subnet 1 route table association
resource "aws_route_table_association" "prisub-1-association" {
    subnet_id = aws_subnet.prisub-1.id
    route_table_id = aws_route_table.private-route-table.id
}

# Private subnet 2 route table association
resource "aws_route_table_association" "prisub-2-association" {
    subnet_id = aws_subnet.prisub-2.id
    route_table_id = aws_route_table.private-route-table.id
}


