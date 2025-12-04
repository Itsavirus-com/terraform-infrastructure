# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []
    content {
      enabled = access_logs.value.enabled
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb"
  })
}

# Default Target Group
resource "aws_lb_target_group" "default" {
  count = var.create_default_target_group ? 1 : 0

  name     = "${var.name_prefix}-default-tg"
  port     = var.default_target_group_port
  protocol = var.default_target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = var.default_health_check_enabled
    healthy_threshold   = var.default_health_check_healthy_threshold
    interval            = var.default_health_check_interval
    matcher             = var.default_health_check_matcher
    path                = var.default_health_check_path
    port                = var.default_health_check_port
    protocol            = var.default_health_check_protocol
    timeout             = var.default_health_check_timeout
    unhealthy_threshold = var.default_health_check_unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-default-tg"
  })
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  count = var.create_http_listener ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = var.http_listener_default_action.type

    dynamic "redirect" {
      for_each = var.http_listener_default_action.type == "redirect" ? [var.http_listener_default_action.redirect] : []
      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        status_code = redirect.value.status_code
      }
    }

    dynamic "forward" {
      for_each = var.http_listener_default_action.type == "forward" ? [var.http_listener_default_action.forward] : []
      content {
        target_group {
          arn = var.create_default_target_group ? aws_lb_target_group.default[0].arn : forward.value.target_group_arn
        }
      }
    }

    dynamic "fixed_response" {
      for_each = var.http_listener_default_action.type == "fixed-response" ? [var.http_listener_default_action.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-http-listener"
  })
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count = var.create_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type = var.https_listener_default_action.type

    dynamic "forward" {
      for_each = var.https_listener_default_action.type == "forward" ? [var.https_listener_default_action.forward] : []
      content {
        target_group {
          arn = var.create_default_target_group ? aws_lb_target_group.default[0].arn : forward.value.target_group_arn
        }
      }
    }

    dynamic "fixed_response" {
      for_each = var.https_listener_default_action.type == "fixed-response" ? [var.https_listener_default_action.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-https-listener"
  })
} 