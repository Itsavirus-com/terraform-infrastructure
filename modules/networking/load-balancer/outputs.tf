output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = aws_lb.main.id
}

output "default_target_group_arn" {
  description = "ARN of the default target group"
  value       = var.create_default_target_group ? aws_lb_target_group.default[0].arn : null
}

output "default_target_group_id" {
  description = "ID of the default target group"
  value       = var.create_default_target_group ? aws_lb_target_group.default[0].id : null
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = var.create_http_listener ? aws_lb_listener.http[0].arn : null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.create_https_listener ? aws_lb_listener.https[0].arn : null
} 