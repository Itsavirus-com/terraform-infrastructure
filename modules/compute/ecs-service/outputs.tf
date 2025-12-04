output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.service.name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.service.id
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.task.arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = aws_ecs_task_definition.task.family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = aws_ecs_task_definition.task.revision
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = var.create_ecr_repository ? aws_ecr_repository.repository[0].repository_url : null
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = var.create_ecr_repository ? aws_ecr_repository.repository[0].arn : null
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = var.create_target_group ? aws_lb_target_group.target_group[0].arn : null
}

output "target_group_name" {
  description = "Name of the target group"
  value       = var.create_target_group ? aws_lb_target_group.target_group[0].name : null
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.service_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.service_logs.arn
}

output "listener_rule_arn" {
  description = "ARN of the listener rule"
  value       = var.create_listener_rule ? aws_lb_listener_rule.listener_rule[0].arn : null
} 