variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 20
    error_message = "Name prefix must be between 1 and 20 characters."
  }
}

variable "vpc_id" {
  description = "VPC ID where the load balancer will be created"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
  validation {
    condition     = length(var.subnets) >= 2
    error_message = "At least 2 subnets must be provided for high availability."
  }
}

variable "security_groups" {
  description = "List of security group IDs for the load balancer"
  type        = list(string)
}

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
  validation {
    condition     = contains(["application", "network"], var.load_balancer_type)
    error_message = "Load balancer type must be either application or network."
  }
}

variable "internal" {
  description = "If true, the load balancer will be internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "access_logs" {
  description = "Access logs configuration"
  type = object({
    enabled = bool
    bucket  = string
    prefix  = string
  })
  default = null
}

# Default Target Group Configuration
variable "create_default_target_group" {
  description = "Create a default target group"
  type        = bool
  default     = true
}

variable "default_target_group_port" {
  description = "Port for the default target group"
  type        = number
  default     = 80
}

variable "default_target_group_protocol" {
  description = "Protocol for the default target group"
  type        = string
  default     = "HTTP"
}

# Default Health Check Configuration
variable "default_health_check_enabled" {
  description = "Enable health check for default target group"
  type        = bool
  default     = true
}

variable "default_health_check_healthy_threshold" {
  description = "Number of consecutive health checks before marking as healthy"
  type        = number
  default     = 2
}

variable "default_health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "default_health_check_matcher" {
  description = "HTTP response codes for successful health checks"
  type        = string
  default     = "200"
}

variable "default_health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "default_health_check_port" {
  description = "Health check port"
  type        = string
  default     = "traffic-port"
}

variable "default_health_check_protocol" {
  description = "Health check protocol"
  type        = string
  default     = "HTTP"
}

variable "default_health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "default_health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks before marking as unhealthy"
  type        = number
  default     = 2
}

# HTTP Listener Configuration
variable "create_http_listener" {
  description = "Create HTTP listener"
  type        = bool
  default     = true
}

variable "http_listener_default_action" {
  description = "Default action for HTTP listener"
  type = object({
    type = string
    redirect = optional(object({
      port        = string
      protocol    = string
      status_code = string
    }))
    forward = optional(object({
      target_group_arn = string
    }))
    fixed_response = optional(object({
      content_type = string
      message_body = string
      status_code  = string
    }))
  })
  default = {
    type = "forward"
    forward = {
      target_group_arn = null
    }
  }
}

# HTTPS Listener Configuration
variable "create_https_listener" {
  description = "Create HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "https_listener_default_action" {
  description = "Default action for HTTPS listener"
  type = object({
    type = string
    forward = optional(object({
      target_group_arn = string
    }))
    fixed_response = optional(object({
      content_type = string
      message_body = string
      status_code  = string
    }))
  })
  default = {
    type = "forward"
    forward = {
      target_group_arn = null
    }
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
} 