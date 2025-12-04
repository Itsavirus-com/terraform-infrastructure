# ECR Repository
resource "aws_ecr_repository" "repository" {
  count = var.create_ecr_repository ? 1 : 0

  name                 = "${var.service_name}-repository"
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = merge(var.tags, {
    Name = "${var.service_name}-ecr"
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "service_logs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.service_name}-logs"
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.service_name}-task-def"
  execution_role_arn       = var.execution_role_arn
  task_role_arn           = var.task_role_arn
  requires_compatibilities = var.requires_compatibilities
  network_mode            = var.network_mode
  cpu                     = var.task_cpu
  memory                  = var.task_memory

  container_definitions = jsonencode([
    {
      name      = "${var.service_name}-container"
      image     = var.create_ecr_repository ? "${aws_ecr_repository.repository[0].repository_url}:${var.image_tag}" : var.container_image
      essential = true

      environmentFiles = var.environment_files
      environment      = var.environment_variables
      secrets         = var.secrets

      portMappings = var.port_mappings

      memory = var.container_memory
      cpu    = var.container_cpu

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.service_logs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = var.health_check != null ? var.health_check : null
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.service_name}-task-def"
  })
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "${var.service_name}-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  # Load balancer configuration (optional)
  dynamic "load_balancer" {
    for_each = var.load_balancer_config != null ? [var.load_balancer_config] : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = "${var.service_name}-container"
      container_port   = load_balancer.value.container_port
    }
  }

  # Network configuration for Fargate
  dynamic "network_configuration" {
    for_each = var.network_configuration != null ? [var.network_configuration] : []
    content {
      subnets         = network_configuration.value.subnets
      security_groups = network_configuration.value.security_groups
    }
  }

  # # Deployment configuration
  # deployment_configuration {
  #   maximum_percent         = var.deployment_maximum_percent
  #   minimum_healthy_percent = var.deployment_minimum_healthy_percent
  # }

  tags = merge(var.tags, {
    Name = "${var.service_name}-service"
  })

  depends_on = [aws_ecs_task_definition.task]
}

# Load Balancer Target Group (optional)
resource "aws_lb_target_group" "target_group" {
  count = var.create_target_group ? 1 : 0

  name        = "${var.service_name}-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = "${var.service_name}-tg"
  })
}

# Load Balancer Listener Rule (optional)
resource "aws_lb_listener_rule" "listener_rule" {
  count = var.create_listener_rule ? 1 : 0

  listener_arn = var.listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[0].arn
  }

  dynamic "condition" {
    for_each = var.listener_rule_conditions
    content {
      dynamic "path_pattern" {
        for_each = condition.value.path_pattern != null ? [condition.value.path_pattern] : []
        content {
          values = path_pattern.value
        }
      }
      
      dynamic "host_header" {
        for_each = condition.value.host_header != null ? [condition.value.host_header] : []
        content {
          values = host_header.value
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.service_name}-listener-rule"
  })
} 