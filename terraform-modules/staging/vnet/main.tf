# Create VPC
resource "aws_vpc" "vpc" {
    cidr_block = var.VPC_CIDR
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.PROJECT}-vpc"
    }
}

# Create internet gateway for the public subnet
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "${var.PROJECT}-igw"
    }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.PUBLIC_SUBNETS_CIDR)
  cidr_block = element(var.PUBLIC_SUBNETS_CIDR, count.index)
  availability_zone = element(var.AVAILABILITY_ZONE, count.index)
  tags = {
    Name = "${var.PROJECT}-${element(var.AVAILABILITY_ZONE, count.index)}-public-subnet"
  }
}

# Create routing table for public subnet
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.PROJECT}-public-route-table"
    }
}

# Create public internet gateway for public subnet
resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
}

# Create route table subnet associations
resource "aws_route_table_association" "public" {
    count = length(var.PUBLIC_SUBNETS_CIDR)
    subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
    route_table_id = aws_route_table.public.id
}

# Create VPC's default security group
resource "aws_security_group" "sg" {
    name = "${var.PROJECT}-sg"
    description = "Default security group to allow inbound/outbound from the VPC"
    vpc_id = aws_vpc.vpc.id
    depends_on = [
      aws_vpc.vpc
    ]

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "22"
      to_port = "22"
      protocol = "TCP"
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "80"
      to_port = "80"
      protocol = "TCP"
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "443"
      to_port = "443"
      protocol = "TCP"
    }
    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "3000"
      to_port = "3000"
      protocol = "TCP"
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "996"
      to_port = "996"
      protocol = "TCP"
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "7946"
      to_port = "7946"
      protocol = "TCP"
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "4789"
      to_port = "4789"
      protocol = "TCP"
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "2377"
      to_port = "2377"
      protocol = "TCP"
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "7946"
      to_port = "7946"
      protocol = "UDP"
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "4789"
      to_port = "4789"
      protocol = "UDP"
    }

    ingress {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = "2377"
      to_port = "2377"
      protocol = "UDP"
    }

    ingress {
      cidr_blocks = var.ALLOWED_IP
      from_port = "5432"
      to_port = "5432"
      protocol = "TCP"
    }

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}