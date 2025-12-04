# AWS Credentials
variable "access_key" {
  description = "Access key to AWS console"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "Secret key to AWS console"
  type        = string
  sensitive   = true
}

variable "aws_profile" {
  description = "AWS profile to use (alternative to access_key/secret_key)"
  type        = string
  default     = ""
}

# Project Configuration
variable "project_name" {
  description = "Name of the MobyPark project"
  type        = string
  default     = "mobypark-prod"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
}

# Domain and SSL Configuration
variable "domain_name" {
  description = "Primary domain name for MobyPark"
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

# ECS Cluster Configuration
variable "ecs_instance_type" {
  description = "EC2 instance type for ECS cluster"
  type        = string
  default     = "t3.small"
}

variable "ec2_key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = ""
}

variable "ecs_min_instances" {
  description = "Minimum number of ECS instances"
  type        = number
  default     = 2
}

variable "ecs_max_instances" {
  description = "Maximum number of ECS instances"
  type        = number
  default     = 20
}

variable "ecs_desired_instances" {
  description = "Desired number of ECS instances"
  type        = number
  default     = 2
}

# MobyPark Service Configuration
variable "backend_desired_count" {
  description = "Desired number of backend API tasks"
  type        = number
  default     = 1
}

variable "frontend_desired_count" {
  description = "Desired number of frontend web tasks"
  type        = number
  default     =2
}

variable "admin_desired_count" {
  description = "Desired number of admin dashboard tasks"
  type        = number
  default     = 1
}

variable "worker_desired_count" {
  description = "Desired number of background worker tasks"
  type        = number
  default     = 2
} 