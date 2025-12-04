output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = var.create_ecs_execution_role ? aws_iam_role.ecs_execution_role[0].arn : ""
}

output "ecs_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = var.create_ecs_execution_role ? aws_iam_role.ecs_execution_role[0].name : ""
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = var.create_ecs_task_role ? aws_iam_role.ecs_task_role[0].arn : ""
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = var.create_ecs_task_role ? aws_iam_role.ecs_task_role[0].name : ""
}

output "role_arns" {
  description = "Map of all created role ARNs"
  value = {
    execution_role = var.create_ecs_execution_role ? aws_iam_role.ecs_execution_role[0].arn : ""
    task_role      = var.create_ecs_task_role ? aws_iam_role.ecs_task_role[0].arn : ""
  }
} 