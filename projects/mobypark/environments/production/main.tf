# Data source for ECS optimized AMI
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

# VPC and Networking
module "vpc" {
  source = "../../../../modules/networking/vpc"

  name_prefix          = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = local.common_tags
}

# Security Groups
module "security_groups" {
  source = "../../../../modules/security/security-groups"

  name_prefix = var.project_name
  vpc_id      = module.vpc.vpc_id

  # Enable all security groups
  create_database_sg      = true
  create_load_balancer_sg = true
  create_application_sg   = true

  # Database configuration (PostgreSQL for MobyPark)
  database_port = 5432

  # Custom application rules for MobyPark services
  application_ingress_rules = [
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "MobyPark API backend port"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "MobyPark frontend port"
    },
    {
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "MobyPark admin dashboard port"
    }
  ]

  tags = local.common_tags
}

# ACM Certificate for MobyPark domain
module "acm_certificate" {
  source = "../../../../modules/security/acm"

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  route53_zone_name        = var.route53_zone_name
  validation_method        = "DNS"
  wait_for_validation      = true

  tags = local.common_tags
}

# IAM Roles for MobyPark services
module "iam_roles" {
  source = "../../../../modules/security/iam"

  name_prefix = var.project_name

  # Execution role with basic permissions
  create_ecs_execution_role = true
  enable_secrets_manager   = false

  # Task role with basic permissions for MobyPark services
  create_ecs_task_role         = true
  enable_task_cloudwatch_access = true

  tags = local.common_tags
}

# ECS Cluster with Auto Scaling for MobyPark
module "ecs_cluster" {
  source = "../../../../modules/compute/ecs-cluster"

  name_prefix        = var.project_name
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.application_security_group_id]

  # EC2 Configuration
  ami_id        = data.aws_ami.ecs_optimized.id
  instance_type = var.ecs_instance_type
  key_name      = var.ec2_key_name

  # Auto Scaling Configuration
  min_size         = var.ecs_min_instances
  max_size         = var.ecs_max_instances
  desired_capacity = var.ecs_desired_instances

  # Storage configuration
  root_volume_size    = 50
  encrypt_root_volume = true

  # Monitoring
  enable_container_insights = true

  # Capacity provider configuration
  target_capacity = 85
  managed_scaling_status = "ENABLED"

  tags = local.common_tags
}

# Application Load Balancer for MobyPark
module "load_balancer" {
  source = "../../../../modules/networking/load-balancer"

  name_prefix     = var.project_name
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.security_groups.load_balancer_security_group_id]

  # HTTP to HTTPS redirect
  create_http_listener = true
  http_listener_default_action = {
    type = "redirect"
    redirect = {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  # HTTPS listener with modern SSL policy
  create_https_listener = true
  certificate_arn       = module.acm_certificate.certificate_arn
  ssl_policy           = "ELBSecurityPolicy-TLS-1-2-2017-01"

  tags = local.common_tags
}

# MobyPark Backend API Service
module "backend_service" {
  source = "../../../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-backend"
  cluster_id      = module.ecs_cluster.cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # Container Configuration
  create_ecr_repository = true
  container_memory      = 2048
  container_cpu         = 1024
  desired_count        = var.backend_desired_count

  # IAM Roles
  execution_role_arn = module.iam_roles.ecs_execution_role_arn
  task_role_arn      = module.iam_roles.ecs_task_role_arn

  # Environment Configuration
  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "SERVICE_NAME"
      value = "mobypark-backend"
    }
  ]

  # Load Balancer Integration
  create_target_group = true
  target_group_port   = 8000
  target_type        = "instance"

  load_balancer_config = {
    target_group_arn = null
    container_port   = 8000
  }

  # API routing
  create_listener_rule    = true
  listener_arn           = module.load_balancer.https_listener_arn
  listener_rule_priority = 100
  listener_rule_conditions = [
    {
      path_pattern = ["/api/*", "/health", "/docs"]
      host_header  = null
    }
  ]

  # Health Check
  health_check_path = "/health"
  health_check_matcher = "200"

  tags = merge(local.common_tags, {
    Service = "backend"
    Component = "api"
  })
}

# MobyPark Frontend Web Application
module "frontend_service" {
  source = "../../../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-frontend"
  cluster_id      = module.ecs_cluster.cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # Container Configuration
  create_ecr_repository = true
  container_memory      = 0
  container_cpu         = 0
  desired_count        = var.frontend_desired_count

  # IAM Roles
  execution_role_arn = module.iam_roles.ecs_execution_role_arn
  task_role_arn      = module.iam_roles.ecs_task_role_arn

  # Port Configuration
  port_mappings = [
    {
      containerPort = 3000
      hostPort      = 0
      protocol      = "tcp"
    }
  ]

  # Environment variables for frontend
  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "API_BASE_URL"
      value = "https://${var.domain_name}/api"
    }
  ]

  # Load Balancer Integration
  create_target_group = true
  target_group_port   = 3000
  target_type        = "instance"

  load_balancer_config = {
    target_group_arn = null
    container_port   = 3000
  }

  # Frontend routing (catch-all for SPA)
  create_listener_rule    = true
  listener_arn           = module.load_balancer.https_listener_arn
  listener_rule_priority = 300
  listener_rule_conditions = [
    {
      path_pattern = ["/*"]
      host_header  = null
    }
  ]

  tags = merge(local.common_tags, {
    Service = "frontend"
    Component = "web"
  })
}

# MobyPark Admin Dashboard Service
module "admin_service" {
  source = "../../../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-admin"
  cluster_id      = module.ecs_cluster.cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # Container Configuration
  create_ecr_repository = true
  container_memory      = 1024
  container_cpu         = 512
  desired_count        = var.admin_desired_count

  # IAM Roles
  execution_role_arn = module.iam_roles.ecs_execution_role_arn
  task_role_arn      = module.iam_roles.ecs_task_role_arn

  # Port Configuration
  port_mappings = [
    {
      containerPort = 9000
      hostPort      = 0
      protocol      = "tcp"
    }
  ]

  # Environment Configuration
  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "SERVICE_NAME"
      value = "mobypark-admin"
    }
  ]

  # Load Balancer Integration
  create_target_group = true
  target_group_port   = 9000
  target_type        = "instance"

  load_balancer_config = {
    target_group_arn = null
    container_port   = 9000
  }

  # Admin dashboard routing
  create_listener_rule    = true
  listener_arn           = module.load_balancer.https_listener_arn
  listener_rule_priority = 200
  listener_rule_conditions = [
    {
      path_pattern = ["/admin/*"]
      host_header  = null
    }
  ]

  tags = merge(local.common_tags, {
    Service = "admin"
    Component = "dashboard"
  })
}

# MobyPark Background Jobs Service
module "worker_service" {
  source = "../../../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-worker"
  cluster_id      = module.ecs_cluster.cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # Container Configuration
  create_ecr_repository = true
  container_memory      = 1024
  container_cpu         = 512
  desired_count        = var.worker_desired_count

  # IAM Roles
  execution_role_arn = module.iam_roles.ecs_execution_role_arn
  task_role_arn      = module.iam_roles.ecs_task_role_arn

  # Environment Configuration
  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "SERVICE_NAME"
      value = "mobypark-worker"
    }
  ]

  # No load balancer for background workers
  create_target_group  = false
  create_listener_rule = false

  tags = merge(local.common_tags, {
    Service = "worker"
    Component = "background-jobs"
  })
}

# Local values
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Client      = "MobyPark"
    ManagedBy   = "terraform"
    CreatedAt   = timestamp()
  }
} 