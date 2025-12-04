# Database Security Group
resource "aws_security_group" "database" {
  count = var.create_database_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-db-"
  description = "Security group for RDS database access"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-sg"
    Type = "Database"
  })
}

resource "aws_security_group_rule" "database_ingress_from_app" {
  count = var.create_database_sg ? 1 : 0

  type                     = "ingress"
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.application[0].id
  security_group_id        = aws_security_group.database[0].id
  description              = "Database access from application"
}

resource "aws_security_group_rule" "database_egress" {
  count = var.create_database_sg ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.database[0].id
  description       = "All outbound traffic"
}

# Load Balancer Security Group
resource "aws_security_group" "load_balancer" {
  count = var.create_load_balancer_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-lb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-lb-sg"
    Type = "LoadBalancer"
  })
}

resource "aws_security_group_rule" "load_balancer_http_ingress" {
  count = var.create_load_balancer_sg ? 1 : 0

  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.load_balancer[0].id
  description       = "HTTP access from internet"
}

resource "aws_security_group_rule" "load_balancer_https_ingress" {
  count = var.create_load_balancer_sg ? 1 : 0

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.load_balancer[0].id
  description       = "HTTPS access from internet"
}

resource "aws_security_group_rule" "load_balancer_ssh_ingress" {
  count = var.create_load_balancer_sg && var.allow_ssh_from_internet ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.load_balancer[0].id
  description       = "SSH access from internet"
}

resource "aws_security_group_rule" "load_balancer_egress" {
  count = var.create_load_balancer_sg ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer[0].id
  description       = "All outbound traffic"
}

# Application Security Group (ECS/EC2)
resource "aws_security_group" "application" {
  count = var.create_application_sg ? 1 : 0

  name_prefix = "${var.name_prefix}-app-"
  description = "Security group for application instances (ECS/EC2)"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-sg"
    Type = "Application"
  })
}

resource "aws_security_group_rule" "application_ingress_from_lb" {
  count = var.create_application_sg && var.create_load_balancer_sg ? 1 : 0

  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.load_balancer[0].id
  security_group_id        = aws_security_group.application[0].id
  description              = "All traffic from load balancer"
}

resource "aws_security_group_rule" "application_ingress_custom" {
  count = length(var.application_ingress_rules)

  type              = "ingress"
  from_port         = var.application_ingress_rules[count.index].from_port
  to_port           = var.application_ingress_rules[count.index].to_port
  protocol          = var.application_ingress_rules[count.index].protocol
  cidr_blocks       = var.application_ingress_rules[count.index].cidr_blocks
  security_group_id = aws_security_group.application[0].id
  description       = var.application_ingress_rules[count.index].description
}

resource "aws_security_group_rule" "application_egress" {
  count = var.create_application_sg ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.application[0].id
  description       = "All outbound traffic"
} 