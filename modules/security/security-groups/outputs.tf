output "database_security_group_id" {
  description = "ID of the database security group"
  value       = var.create_database_sg ? aws_security_group.database[0].id : null
}

output "load_balancer_security_group_id" {
  description = "ID of the load balancer security group"
  value       = var.create_load_balancer_sg ? aws_security_group.load_balancer[0].id : null
}

output "application_security_group_id" {
  description = "ID of the application security group"
  value       = var.create_application_sg ? aws_security_group.application[0].id : null
}

output "security_group_ids" {
  description = "Map of all security group IDs"
  value = {
    database      = var.create_database_sg ? aws_security_group.database[0].id : null
    load_balancer = var.create_load_balancer_sg ? aws_security_group.load_balancer[0].id : null
    application   = var.create_application_sg ? aws_security_group.application[0].id : null
  }
} 