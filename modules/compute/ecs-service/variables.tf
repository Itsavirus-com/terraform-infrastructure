# Service Configuration
variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  validation {
    condition     = length(var.service_name) > 0 && length(var.service_name) <= 50
    error_message = "Service name must be between 1 and 50 characters."
  }
}

variable "cluster_id" {
  description = "ECS cluster ID where service will be deployed"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

# ECR Configuration
variable "create_ecr_repository" {
  description = "Create ECR repository for this service"
  type        = bool
  default     = true
}

variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting for ECR repository"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ECR image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "ecr_force_delete" {
  description = "Force delete ECR repository even if it contains images"
  type        = bool
  default     = false
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

# Container Configuration
variable "container_image" {
  description = "Container image to use (if not using ECR)"
  type        = string
  default     = ""
}

variable "image_tag" {
  description = "Image tag to use"
  type        = string
  default     = "latest"
}

variable "container_memory" {
  description = "Memory (in MB) for the container"
  type        = number
  default     = 512
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
  default     = 256
}

# Task Configuration
variable "task_cpu" {
  description = "CPU units for the task (Fargate only)"
  type        = string
  default     = null
}

variable "task_memory" {
  description = "Memory (in MB) for the task (Fargate only)"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
}

variable "requires_compatibilities" {
  description = "Launch types required by the task definition"
  type        = list(string)
  default     = ["EC2"]
}

variable "network_mode" {
  description = "Network mode for the task definition"
  type        = string
  default     = "bridge"
}

# Service Configuration
variable "desired_count" {
  description = "Desired number of instances of the task definition"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type (EC2 or FARGATE)"
  type        = string
  default     = "EC2"
  validation {
    condition     = contains(["EC2", "FARGATE"], var.launch_type)
    error_message = "Launch type must be either EC2 or FARGATE."
  }
}

# Port Mappings
variable "port_mappings" {
  description = "Port mappings for the container"
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = [
    {
      containerPort = 8000
      hostPort      = 0
      protocol      = "tcp"
    }
  ]
}

# Environment Configuration
variable "environment_files" {
  description = "Environment files for the container"
  type = list(object({
    value = string
    type  = string
  }))
  default = []
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "Secrets for the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# Health Check
variable "health_check" {
  description = "Health check configuration for the container"
  type = object({
    command     = list(string)
    interval    = number
    timeout     = number
    retries     = number
    startPeriod = number
  })
  default = null
}

# Load Balancer Configuration
variable "load_balancer_config" {
  description = "Load balancer configuration"
  type = object({
    target_group_arn = string
    container_port   = number
  })
  default = null
}

variable "network_configuration" {
  description = "Network configuration for Fargate"
  type = object({
    subnets         = list(string)
    security_groups = list(string)
  })
  default = null
}

# Target Group Configuration
variable "create_target_group" {
  description = "Create target group for this service"
  type        = bool
  default     = false
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of target (instance or ip)"
  type        = string
  default     = "instance"
}

# Health Check Configuration
variable "health_check_enabled" {
  description = "Enable health check"
  type        = bool
  default     = true
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks before marking as healthy"
  type        = number
  default     = 2
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "HTTP response codes for successful health checks"
  type        = string
  default     = "200"
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "Health check port"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Health check protocol"
  type        = string
  default     = "HTTP"
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks before marking as unhealthy"
  type        = number
  default     = 2
}

# Listener Rule Configuration
variable "create_listener_rule" {
  description = "Create listener rule for this service"
  type        = bool
  default     = false
}

variable "listener_arn" {
  description = "ARN of the load balancer listener"
  type        = string
  default     = ""
}

variable "listener_rule_priority" {
  description = "Priority for the listener rule"
  type        = number
  default     = 100
}

variable "listener_rule_conditions" {
  description = "Conditions for the listener rule"
  type = list(object({
    path_pattern = list(string)
    host_header  = list(string)
  }))
  default = []
}

# Deployment Configuration
variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can be running during deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of tasks that must remain healthy during deployment"
  type        = number
  default     = 100
}

# Logging Configuration
variable "log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
} 