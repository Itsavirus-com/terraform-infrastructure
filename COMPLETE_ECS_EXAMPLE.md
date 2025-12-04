# Complete ECS System with Auto-Scaling EC2, Load Balancer & ACM

This example demonstrates how to build a **production-ready ECS system** using all the new consolidated modules.

## 🏗️ Architecture Overview

```
Internet → Route53 → ALB (HTTPS) → ECS Services → Auto-Scaling EC2 → RDS
                ↓
            ACM Certificate
```

## 📁 Project Structure

```
projects/my-app/environments/prod/
├── main.tf           # Main infrastructure definition
├── variables.tf      # Input variables
├── outputs.tf        # Outputs
├── terraform.tfvars  # Variable values
├── secrets.tfvars    # Sensitive values
└── backend.tf        # Remote state configuration
```

## 🚀 Complete Implementation

### 1. Main Infrastructure (`main.tf`)

```hcl
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

  # Database configuration
  database_port = 5432  # PostgreSQL

  # Custom application rules
  application_ingress_rules = [
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "Backend API port"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "Frontend port"
    }
  ]

  tags = local.common_tags
}

# ACM Certificate
module "acm_certificate" {
  source = "../../../../modules/security/acm"

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  route53_zone_name        = var.route53_zone_name
  validation_method        = "DNS"
  wait_for_validation      = true

  tags = local.common_tags
}

# IAM Roles
module "iam_roles" {
  source = "../../../../modules/security/iam"

  name_prefix = var.project_name

  # Execution role with S3 access for environment files
  create_ecs_execution_role = true
  enable_s3_env_files      = true
  s3_env_files_arns        = [var.env_s3_arn]

  # Task role with comprehensive permissions
  create_ecs_task_role         = true
  enable_task_s3_access       = true
  enable_task_cloudwatch_access = true
  enable_task_ses_access      = true
  enable_task_sqs_access      = true

  s3_bucket_arns = [
    var.app_storage_s3_arn,
    var.media_storage_s3_arn
  ]

  sqs_queue_arns = [var.email_queue_arn]

  tags = local.common_tags
}

# ECS Cluster with Auto Scaling
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

  # Storage
  root_volume_size    = 50
  encrypt_root_volume = true

  # Container Insights
  enable_container_insights = true

  tags = local.common_tags
}

# Application Load Balancer
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

  # HTTPS listener
  create_https_listener = true
  certificate_arn       = module.acm_certificate.certificate_arn
  ssl_policy           = "ELBSecurityPolicy-TLS-1-2-2017-01"

  tags = local.common_tags
}

# Backend Service
module "backend_service" {
  source = "../../../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-backend"
  cluster_id      = module.ecs_cluster.cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # Container Configuration
  create_ecr_repository = true
  container_memory      = 1024
  container_cpu         = 512
  desired_count        = var.backend_desired_count

  # IAM Roles
  execution_role_arn = module.iam_roles.ecs_execution_role_arn
  task_role_arn      = module.iam_roles.ecs_task_role_arn

  # Environment Configuration
  environment_files = [
    {
      value = "${var.env_s3_arn}/production.env"
      type  = "s3"
    }
  ]

  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "DB_HOST"
      value = var.db_host
    }
  ]

  # Load Balancer Integration
  create_target_group = true
  target_group_port   = 8000
  target_type        = "instance"

  load_balancer_config = {
    target_group_arn = null  # Will use created target group
    container_port   = 8000
  }

  # Listener Rule for API traffic
  create_listener_rule    = true
  listener_arn           = module.load_balancer.https_listener_arn
  listener_rule_priority = 100
  listener_rule_conditions = [
    {
      path_pattern = ["/api/*", "/health"]
      host_header  = null
    }
  ]

  # Health Check
  health_check_path = "/health"
  health_check_matcher = "200"

  tags = merge(local.common_tags, {
    Service = "backend"
  })
}

# Frontend Service
module "frontend_service" {
  source = "../../../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-frontend"
  cluster_id      = module.ecs_cluster.cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # Container Configuration
  create_ecr_repository = true
  container_memory      = 512
  container_cpu         = 256
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

  # Load Balancer Integration
  create_target_group = true
  target_group_port   = 3000
  target_type        = "instance"

  load_balancer_config = {
    target_group_arn = null
    container_port   = 3000
  }

  # Default route (catch-all)
  create_listener_rule    = true
  listener_arn           = module.load_balancer.https_listener_arn
  listener_rule_priority = 200
  listener_rule_conditions = [
    {
      path_pattern = ["/*"]
      host_header  = null
    }
  ]

  tags = merge(local.common_tags, {
    Service = "frontend"
  })
}

# Background Jobs Service
module "cron_service" {
  source = "../../../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-cron"
  cluster_id      = module.ecs_cluster.cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # Container Configuration
  create_ecr_repository = true
  container_memory      = 512
  container_cpu         = 256
  desired_count        = 1

  # IAM Roles
  execution_role_arn = module.iam_roles.ecs_execution_role_arn
  task_role_arn      = module.iam_roles.ecs_task_role_arn

  # Environment Configuration
  environment_files = [
    {
      value = "${var.env_s3_arn}/production.env"
      type  = "s3"
    }
  ]

  # No load balancer for background jobs
  create_target_group  = false
  create_listener_rule = false

  tags = merge(local.common_tags, {
    Service = "cron"
  })
}

# Local values
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    CreatedAt   = timestamp()
  }
}
```

### 2. Variables (`variables.tf`)

```hcl
# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

# Domain and SSL
variable "domain_name" {
  description = "Primary domain name"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names for SSL certificate"
  type        = list(string)
  default     = []
}

variable "route53_zone_name" {
  description = "Route53 hosted zone name"
  type        = string
}

# ECS Configuration
variable "ecs_instance_type" {
  description = "EC2 instance type for ECS cluster"
  type        = string
  default     = "t3.medium"
}

variable "ec2_key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = ""
}

variable "ecs_min_instances" {
  description = "Minimum number of ECS instances"
  type        = number
  default     = 1
}

variable "ecs_max_instances" {
  description = "Maximum number of ECS instances"
  type        = number
  default     = 10
}

variable "ecs_desired_instances" {
  description = "Desired number of ECS instances"
  type        = number
  default     = 2
}

# Service Configuration
variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 2
}

variable "frontend_desired_count" {
  description = "Desired number of frontend tasks"
  type        = number
  default     = 2
}

# External Resources
variable "env_s3_arn" {
  description = "S3 ARN for environment files"
  type        = string
}

variable "app_storage_s3_arn" {
  description = "S3 ARN for application storage"
  type        = string
}

variable "media_storage_s3_arn" {
  description = "S3 ARN for media storage"
  type        = string
}

variable "email_queue_arn" {
  description = "SQS queue ARN for email processing"
  type        = string
}

variable "db_host" {
  description = "Database host"
  type        = string
}
```

### 3. Variable Values (`terraform.tfvars`)

```hcl
# Project
project_name = "myapp"
environment  = "prod"
aws_region   = "us-west-2"

# Domain
domain_name               = "myapp.com"
subject_alternative_names = ["www.myapp.com", "api.myapp.com"]
route53_zone_name        = "myapp.com."

# ECS Configuration
ecs_instance_type     = "t3.large"
ec2_key_name         = "myapp-prod-key"
ecs_min_instances    = 2
ecs_max_instances    = 20
ecs_desired_instances = 4

# Service Scaling
backend_desired_count  = 3
frontend_desired_count = 2

# External Resources (these would be created separately)
env_s3_arn           = "arn:aws:s3:::myapp-prod-config"
app_storage_s3_arn   = "arn:aws:s3:::myapp-prod-storage"
media_storage_s3_arn = "arn:aws:s3:::myapp-prod-media"
email_queue_arn      = "arn:aws:sqs:us-west-2:123456789012:myapp-prod-email-queue"
db_host              = "myapp-prod.cluster-xyz.us-west-2.rds.amazonaws.com"
```

### 4. Outputs (`outputs.tf`)

```hcl
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.load_balancer.load_balancer_dns_name
}

output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = module.acm_certificate.certificate_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "backend_ecr_url" {
  description = "ECR repository URL for backend service"
  value       = module.backend_service.ecr_repository_url
}

output "frontend_ecr_url" {
  description = "ECR repository URL for frontend service"
  value       = module.frontend_service.ecr_repository_url
}

output "cron_ecr_url" {
  description = "ECR repository URL for cron service"
  value       = module.cron_service.ecr_repository_url
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}
```

### 5. Backend Configuration (`backend.tf`)

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "myapp-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "myapp-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}
```

## 🚀 Deployment Instructions

### 1. Prerequisites

```bash
# Install required tools
brew install terraform aws-cli

# Configure AWS credentials
aws configure

# Clone your terraform repository
git clone <your-repo>
cd terraform-infra/projects/myapp/environments/prod
```

### 2. Initialize Terraform

```bash
# Initialize backend and download providers
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

### 3. Plan and Apply

```bash
# Create execution plan
terraform plan -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Apply changes
terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"
```

### 4. Deploy Applications

After infrastructure is ready, deploy your applications:

```bash
# Get ECR login token
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com

# Build and push backend
docker build -t myapp-backend .
docker tag myapp-backend:latest <backend-ecr-url>:latest
docker push <backend-ecr-url>:latest

# Build and push frontend
docker build -t myapp-frontend .
docker tag myapp-frontend:latest <frontend-ecr-url>:latest
docker push <frontend-ecr-url>:latest

# Update ECS services to use new images
aws ecs update-service --cluster myapp-prod-cluster --service myapp-prod-backend-service --force-new-deployment
aws ecs update-service --cluster myapp-prod-cluster --service myapp-prod-frontend-service --force-new-deployment
```

## 🔍 Monitoring & Troubleshooting

### CloudWatch Logs

```bash
# View service logs
aws logs tail /ecs/myapp-prod-backend --follow
aws logs tail /ecs/myapp-prod-frontend --follow
```

### ECS Service Status

```bash
# Check service status
aws ecs describe-services --cluster myapp-prod-cluster --services myapp-prod-backend-service
```

### Auto Scaling Monitoring

```bash
# Check ASG status
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names myapp-prod-ecs-asg
```

## ✨ Key Features

- ✅ **Auto-scaling EC2 instances** with ECS capacity providers
- ✅ **SSL/TLS termination** with ACM certificates
- ✅ **Load balancing** with health checks and routing rules
- ✅ **Container insights** for monitoring
- ✅ **Secure IAM roles** with least privilege
- ✅ **Environment file injection** from S3
- ✅ **Multi-service architecture** (frontend, backend, cron)
- ✅ **High availability** across multiple AZs
- ✅ **Encrypted storage** and secure networking

This setup provides a **production-ready, scalable ECS infrastructure** that can handle real-world workloads! 🚀
