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

# Keypair created for SSH into instance

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "keypair.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "key" {
  key_name   = "keypair"
  public_key = tls_private_key.key.public_key_openssh
}

# Security group created for HTTP, HTTPS and SSH access

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow Jenkins"
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr_blocks]
  }

  tags = {
    Name = "${local.name}-jenkins-sg"
  }
}

# Security group created for SonarQube access

resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube-sg"
  description = "Allow HTTP, HTTPS, SSH and SonarQube traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH - Port 22"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow HTTP - Port 80"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow HTTPS - Port 443"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow SonarQube - Port 9000"
    from_port   = var.sonar_port
    to_port     = var.sonar_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr_blocks]
  }

  tags = {
    Name = "${local.name}-sonarqube-sg"
  }
}

# Security group created for Ansible access
resource "aws_security_group" "ansible_sg" {
  name        = "ansible-sg"
  description = "Allow SSH traffic for Ansible"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH - Port 22"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr_blocks]
  }

  tags = {
    Name = "${local.name}-ansible-sg"
  }
}

# Security group created for Docker access
resource "aws_security_group" "docker_sg" {
  name        = "docker-sg"
  description = "Allow HTTP, HTTPS, SSH and Docker traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH - Port 22"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow HTTP - Port 80"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow HTTPS - Port 443"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow Docker - Port 2375"
    from_port   = var.docker_port
    to_port     = var.docker_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow Docker TLS - Port 2376"
    from_port   = var.dockertls_port
    to_port     = var.dockertls_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr_blocks]
  }

  tags = {
    Name = "${local.name}-docker-sg"
  }
}

# Security group created for Nexus access
resource "aws_security_group" "nexus_sg" {
  name        = "nexus-sg"
  description = "Allow HTTP, HTTPS, SSH and Nexus traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH - Port 22"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow HTTP - Port 80"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow HTTPS - Port 443"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  ingress {
    description = "Allow Nexus - Port 8081"
    from_port   = var.nexus_port
    to_port     = var.nexus_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_blocks]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr_blocks]
  }

  tags = {
    Name = "${local.name}-nexus-sg"
  }
}

# Security group created for RDS access
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow RDS database traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow MySQL RDS - Port 3306"
    from_port   = var.mysql_port
    to_port     = var.mysql_port
    protocol    = "tcp"
    cidr_blocks = [var.rds_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr_blocks]
  }

  tags = {
    Name = "${local.name}-rds-sg"
  }
}


