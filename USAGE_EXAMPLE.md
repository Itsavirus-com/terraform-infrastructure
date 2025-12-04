# New Module Usage Examples

This document shows how to use the new consolidated modules to replace your current scattered module structure.

## Complete Infrastructure Example

Here's how to build a complete infrastructure stack using the new modules:

### 1. VPC and Networking

```hcl
# modules usage in your project main.tf
module "vpc" {
  source = "../../modules/networking/vpc"

  name_prefix          = var.project_name
  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["us-west-2a", "us-west-2b", "us-west-2c"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
```

### 2. Security Groups

```hcl
module "security_groups" {
  source = "../../modules/security/security-groups"

  name_prefix = var.project_name
  vpc_id      = module.vpc.vpc_id

  # Enable all security groups
  create_database_sg      = true
  create_load_balancer_sg = true
  create_application_sg   = true

  # Database configuration
  database_port = 5432  # PostgreSQL

  # Custom ingress rules for application
  application_ingress_rules = [
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Application port from VPC"
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
```

### 3. Load Balancer

```hcl
module "load_balancer" {
  source = "../../modules/networking/load-balancer"

  name_prefix     = var.project_name
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.security_groups.load_balancer_security_group_id]

  # HTTP listener with redirect to HTTPS
  create_http_listener = true
  http_listener_default_action = {
    type = "redirect"
    redirect = {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  # HTTPS listener (if you have SSL certificate)
  create_https_listener = var.certificate_arn != ""
  certificate_arn       = var.certificate_arn

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
```

### 4. ECS Services

#### Backend Service

```hcl
module "backend_service" {
  source = "../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-backend"
  cluster_id      = var.ecs_cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # ECR and Container Configuration
  create_ecr_repository = true
  container_memory      = 512
  container_cpu         = 256

  # Task Configuration
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  # Environment Configuration
  environment_files = [
    {
      value = "${var.env_s3_arn}/production.env"
      type  = "s3"
    }
  ]

  # Load Balancer Integration
  create_target_group = true
  target_group_port   = 8000

  load_balancer_config = {
    target_group_arn = null  # Will use the created target group
    container_port   = 8000
  }

  # Listener Rule
  create_listener_rule    = true
  listener_arn           = module.load_balancer.https_listener_arn
  listener_rule_priority = 100
  listener_rule_conditions = [
    {
      path_pattern = ["/api/*"]
      host_header  = null
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Service     = "backend"
  }
}
```

#### Frontend Service

```hcl
module "frontend_service" {
  source = "../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-frontend"
  cluster_id      = var.ecs_cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # ECR and Container Configuration
  create_ecr_repository = true
  container_memory      = 256
  container_cpu         = 128

  # Task Configuration
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  # Load Balancer Integration
  create_target_group = true
  target_group_port   = 80

  load_balancer_config = {
    target_group_arn = null
    container_port   = 80
  }

  # Listener Rule (default route)
  create_listener_rule    = true
  listener_arn           = module.load_balancer.https_listener_arn
  listener_rule_priority = 200
  listener_rule_conditions = [
    {
      path_pattern = ["/*"]
      host_header  = null
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Service     = "frontend"
  }
}
```

#### Cron Service (Background Jobs)

```hcl
module "cron_service" {
  source = "../../modules/compute/ecs-service"

  service_name    = "${var.project_name}-cron"
  cluster_id      = var.ecs_cluster_id
  region          = var.aws_region
  vpc_id          = module.vpc.vpc_id

  # ECR and Container Configuration
  create_ecr_repository = true
  container_memory      = 256
  container_cpu         = 128

  # Task Configuration
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  # No load balancer for cron jobs
  create_target_group  = false
  create_listener_rule = false

  # Environment Configuration
  environment_files = [
    {
      value = "${var.env_s3_arn}/production.env"
      type  = "s3"
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Service     = "cron"
  }
}
```

## Migration Strategy

### Step 1: Update One Project at a Time

Start with a non-production project. For example, update `projects/factum/environments/staging/main.tf`:

```hcl
# OLD (multiple scattered modules):
# module "vnet" {
#   source = "../../../../terraform-modules/production/production-ecs-new/vnet"
#   # ... many variables
# }

# NEW (clean, focused modules):
module "vpc" {
  source = "../../../../modules/networking/vpc"

  name_prefix          = "factum-staging"
  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["us-west-2a", "us-west-2b"]
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

  tags = local.tags
}

module "security_groups" {
  source = "../../../../modules/security/security-groups"

  name_prefix = "factum-staging"
  vpc_id      = module.vpc.vpc_id

  tags = local.tags
}

module "load_balancer" {
  source = "../../../../modules/networking/load-balancer"

  name_prefix     = "factum-staging"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.security_groups.load_balancer_security_group_id]

  tags = local.tags
}

module "backend_service" {
  source = "../../../../modules/compute/ecs-service"

  service_name       = "factum-staging-backend"
  cluster_id         = var.ecs_cluster_id
  region            = var.aws_region
  vpc_id            = module.vpc.vpc_id
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn     = var.ecs_task_role_arn

  create_target_group = true
  load_balancer_config = {
    target_group_arn = null
    container_port   = 8000
  }

  tags = local.tags
}

locals {
  tags = {
    Environment = "staging"
    Project     = "factum"
    ManagedBy   = "terraform"
  }
}
```

### Step 2: Variables File

Update your `variables.tf`:

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ECS execution role ARN"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "certificate_arn" {
  description = "SSL certificate ARN for HTTPS"
  type        = string
  default     = ""
}

variable "env_s3_arn" {
  description = "S3 ARN for environment files"
  type        = string
}
```

## Benefits of New Structure

1. **🎯 Single Responsibility**: Each module has one clear purpose
2. **🔄 Reusability**: Same modules work across all projects and environments
3. **🛡️ Consistency**: Standardized interfaces and patterns
4. **🔧 Maintainability**: Easy to update and troubleshoot
5. **📚 Documentation**: Clear inputs, outputs, and validation
6. **🧪 Testability**: Focused modules are easier to test

## Next Steps

1. ✅ **Validate**: Test new modules in staging environment
2. ✅ **Migrate**: Convert one project at a time
3. ✅ **Document**: Update team documentation
4. ✅ **Train**: Ensure team understands new patterns
5. ✅ **Cleanup**: Remove old modules after successful migration
