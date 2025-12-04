# Load Balancer Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.load_balancer.load_balancer_zone_id
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.load_balancer.load_balancer_arn
}

# SSL Certificate Outputs
output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = module.acm_certificate.certificate_arn
}

output "certificate_domain_name" {
  description = "Domain name of the SSL certificate"
  value       = module.acm_certificate.certificate_domain_name
}

# ECS Cluster Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

output "capacity_provider_name" {
  description = "Name of the ECS capacity provider"
  value       = module.ecs_cluster.capacity_provider_name
}

# ECR Repository URLs
output "backend_ecr_url" {
  description = "ECR repository URL for MobyPark backend service"
  value       = module.backend_service.ecr_repository_url
}

output "frontend_ecr_url" {
  description = "ECR repository URL for MobyPark frontend service"
  value       = module.frontend_service.ecr_repository_url
}

output "admin_ecr_url" {
  description = "ECR repository URL for MobyPark admin service"
  value       = module.admin_service.ecr_repository_url
}

output "worker_ecr_url" {
  description = "ECR repository URL for MobyPark worker service"
  value       = module.worker_service.ecr_repository_url
}

# ECS Service Names
output "backend_service_name" {
  description = "Name of the backend ECS service"
  value       = module.backend_service.service_name
}

output "frontend_service_name" {
  description = "Name of the frontend ECS service"
  value       = module.frontend_service.service_name
}

output "admin_service_name" {
  description = "Name of the admin ECS service"
  value       = module.admin_service.service_name
}

output "worker_service_name" {
  description = "Name of the worker ECS service"
  value       = module.worker_service.service_name
}

# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

# Security Group Outputs
output "load_balancer_security_group_id" {
  description = "ID of the load balancer security group"
  value       = module.security_groups.load_balancer_security_group_id
}

output "application_security_group_id" {
  description = "ID of the application security group"
  value       = module.security_groups.application_security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.security_groups.database_security_group_id
}

# IAM Role Outputs
output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.iam_roles.ecs_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.iam_roles.ecs_task_role_arn
}

# Auto Scaling Group Outputs
output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ecs_cluster.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.ecs_cluster.autoscaling_group_arn
}

# Target Group ARNs
output "backend_target_group_arn" {
  description = "ARN of the backend target group"
  value       = module.backend_service.target_group_arn
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group"
  value       = module.frontend_service.target_group_arn
}

output "admin_target_group_arn" {
  description = "ARN of the admin target group"
  value       = module.admin_service.target_group_arn
}

# Quick Access URLs
output "mobypark_urls" {
  description = "Important URLs for MobyPark services"
  value = {
    main_site      = "https://${var.domain_name}"
    api_docs       = "https://${var.domain_name}/docs"
    admin_panel    = "https://${var.domain_name}/admin"
    health_check   = "https://${var.domain_name}/health"
  }
} 