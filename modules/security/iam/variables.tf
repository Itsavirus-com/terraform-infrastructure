variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 20
    error_message = "Name prefix must be between 1 and 20 characters."
  }
}

# ECS Execution Role Configuration
variable "create_ecs_execution_role" {
  description = "Create ECS task execution role"
  type        = bool
  default     = true
}

variable "enable_s3_env_files" {
  description = "Enable S3 access for environment files in execution role"
  type        = bool
  default     = false
}

variable "s3_env_files_arns" {
  description = "List of S3 ARNs for environment files"
  type        = list(string)
  default     = []
}

variable "enable_secrets_manager" {
  description = "Enable Secrets Manager access in execution role"
  type        = bool
  default     = false
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager ARNs"
  type        = list(string)
  default     = []
}

variable "enable_ssm_parameters" {
  description = "Enable SSM Parameter Store access in execution role"
  type        = bool
  default     = false
}

variable "ssm_parameter_arns" {
  description = "List of SSM Parameter ARNs"
  type        = list(string)
  default     = []
}

# ECS Task Role Configuration
variable "create_ecs_task_role" {
  description = "Create ECS task role"
  type        = bool
  default     = true
}

variable "task_role_policy_statements" {
  description = "Custom policy statements for the task role"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = any
  }))
  default = []
}

variable "task_role_managed_policies" {
  description = "List of managed policy ARNs to attach to the task role"
  type        = list(string)
  default     = []
}

# Common Service Access for Task Role
variable "enable_task_s3_access" {
  description = "Enable S3 access for the task role"
  type        = bool
  default     = false
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs for task role access"
  type        = list(string)
  default     = []
}

variable "enable_task_cloudwatch_access" {
  description = "Enable CloudWatch Logs access for the task role"
  type        = bool
  default     = false
}

variable "enable_task_ses_access" {
  description = "Enable SES access for the task role"
  type        = bool
  default     = false
}

variable "enable_task_sqs_access" {
  description = "Enable SQS access for the task role"
  type        = bool
  default     = false
}

variable "sqs_queue_arns" {
  description = "List of SQS queue ARNs for task role access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
} 