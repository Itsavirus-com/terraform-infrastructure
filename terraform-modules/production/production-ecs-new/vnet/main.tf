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

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.PRIVATE_SUBNETS_CIDR, 0)
  availability_zone = element(var.AVAILABILITY_ZONE, 0)

  tags = {
    Name = "${var.PROJECT}-${element(var.AVAILABILITY_ZONE, 0)}-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.PRIVATE_SUBNETS_CIDR, 1)
  availability_zone = element(var.AVAILABILITY_ZONE, 1)

  tags = {
    Name = "${var.PROJECT}-${element(var.AVAILABILITY_ZONE, 1)}-private-subnet-2"
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
# resource "aws_security_group" "ec2" {
#     name = "${var.PROJECT}-ec-sg"
#     description = "Default security group to allow inbound/outbound from the VPC"
#     vpc_id = aws_vpc.vpc.id
#     depends_on = [
#       aws_vpc.vpc
#     ]

#     ingress {
#       cidr_blocks = ["0.0.0.0/0"]
#       from_port = "22"
#       to_port = "22"
#       protocol = "TCP"
#     }

#     ingress {
#       security_groups = [aws_security_group.lb.id]
#       from_port = "80"
#       to_port = "80"
#       protocol = "TCP"
#     }

#     ingress {
#       cidr_blocks = ["0.0.0.0/0"]
#       from_port = "443"
#       to_port = "443"
#       protocol = "TCP"
#     }

#     egress {
#         from_port = "0"
#         to_port = "0"
#         protocol = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
# }

resource "aws_security_group" "db" {
    name = "${var.PROJECT}-db-sg"
    description = "Default security group to allow inbound/outbound from the VPC"
    vpc_id = aws_vpc.vpc.id
    depends_on = [
      aws_vpc.vpc
    ]

    ingress {
      security_groups = [aws_security_group.ecs.id]
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

resource "aws_security_group" "lb" {
    name = "${var.PROJECT}-lb-sg"
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

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ecs" {
  name = "${var.PROJECT}-ecs-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]
    
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lb" "load_balancer" {
  name = "${var.PROJECT}-production-alb"
  load_balancer_type = "application"
  internal = false
  security_groups = [aws_security_group.lb.id]
  subnets = [for subnet in aws_subnet.public_subnet : subnet.id]

  tags = {
    Environment = "production"
  }
}

# resource "aws_lb_target_group" "target_group" {
#   name = "${var.PROJECT}-lb-target-group"
#   port = 80
#   protocol = "HTTP"
#   vpc_id = aws_vpc.vpc.id
# }

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = "${aws_lb.load_balancer.arn}" #  load balancer
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = "${aws_lb_target_group.target_group.arn}" # target group
#   }
# }
