output "lb_arn" {
  value = aws_lb.load_balancer.arn
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}