variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 20
    error_message = "Name prefix must be between 1 and 20 characters."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs where ECS instances will be launched"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets must be provided for high availability."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS instances"
  type        = list(string)
}

# Container Insights
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

# Execute Command Configuration
variable "kms_key_id" {
  description = "KMS key ID for ECS execute command logging encryption"
  type        = string
  default     = ""
}

variable "execute_command_logging" {
  description = "Logging configuration for ECS execute command"
  type        = string
  default     = "DEFAULT"
  validation {
    condition     = contains(["NONE", "DEFAULT", "OVERRIDE"], var.execute_command_logging)
    error_message = "Execute command logging must be one of: NONE, DEFAULT, OVERRIDE."
  }
}

variable "execute_command_log_configuration" {
  description = "Log configuration for ECS execute command"
  type = object({
    cloud_watch_encryption_enabled = bool
    cloud_watch_log_group_name     = string
    s3_bucket_name                 = string
    s3_bucket_encryption_enabled   = bool
    s3_key_prefix                  = string
  })
  default = null
}

variable "create_execute_command_log_group" {
  description = "Create CloudWatch log group for ECS execute command"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# EC2 Configuration
variable "ami_id" {
  description = "AMI ID for ECS instances (leave empty for latest ECS-optimized AMI)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for ECS instances"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = ""
}

# Storage Configuration
variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Type of the root EBS volume"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "Root volume type must be one of: gp2, gp3, io1, io2."
  }
}

variable "encrypt_root_volume" {
  description = "Encrypt the root EBS volume"
  type        = bool
  default     = true
}

# Auto Scaling Configuration
variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "health_check_type" {
  description = "Type of health check for ASG"
  type        = string
  default     = "ELB"
  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "Health check type must be either EC2 or ELB."
  }
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "protect_from_scale_in" {
  description = "Protect instances from scale in"
  type        = bool
  default     = false
}

# Capacity Provider Configuration
variable "managed_termination_protection" {
  description = "Enable managed termination protection"
  type        = bool
  default     = false
}

variable "maximum_scaling_step_size" {
  description = "Maximum step adjustment size"
  type        = number
  default     = 10
}

variable "minimum_scaling_step_size" {
  description = "Minimum step adjustment size"
  type        = number
  default     = 1
}

variable "managed_scaling_status" {
  description = "Status of managed scaling"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.managed_scaling_status)
    error_message = "Managed scaling status must be either ENABLED or DISABLED."
  }
}

variable "target_capacity" {
  description = "Target capacity percentage for the capacity provider"
  type        = number
  default     = 80
  validation {
    condition     = var.target_capacity >= 1 && var.target_capacity <= 100
    error_message = "Target capacity must be between 1 and 100."
  }
}

variable "capacity_provider_base" {
  description = "Base number of tasks to run on this capacity provider"
  type        = number
  default     = 0
}

variable "capacity_provider_weight" {
  description = "Weight for this capacity provider"
  type        = number
  default     = 1
}

# Optional Configuration
variable "target_group_arns" {
  description = "List of target group ARNs to associate with ASG"
  type        = list(string)
  default     = []
}

variable "additional_user_data" {
  description = "Additional user data script to run on instances"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
} 