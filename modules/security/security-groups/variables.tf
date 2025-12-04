variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 20
    error_message = "Name prefix must be between 1 and 20 characters."
  }
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "create_database_sg" {
  description = "Create database security group"
  type        = bool
  default     = true
}

variable "create_load_balancer_sg" {
  description = "Create load balancer security group"
  type        = bool
  default     = true
}

variable "create_application_sg" {
  description = "Create application security group"
  type        = bool
  default     = true
}

variable "database_port" {
  description = "Database port (e.g., 5432 for PostgreSQL, 3306 for MySQL)"
  type        = number
  default     = 5432
  validation {
    condition     = var.database_port > 0 && var.database_port <= 65535
    error_message = "Database port must be between 1 and 65535."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access load balancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid IPv4 CIDR blocks."
  }
}

variable "allow_ssh_from_internet" {
  description = "Allow SSH access from internet through load balancer"
  type        = bool
  default     = false
}

variable "application_ingress_rules" {
  description = "Custom ingress rules for application security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
} 