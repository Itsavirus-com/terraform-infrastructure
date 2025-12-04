output "frontend_ecr_url" {
  value = aws_ecr_repository.frontend_ecr.repository_url
}

output "backend_ecr_url" {
  value = aws_ecr_repository.backend_ecr.repository_url
}

output "app_ecr_url" {
  value = aws_ecr_repository.app_ecr.repository_url
}

output "cron_ecr_url" {
  value = aws_ecr_repository.cron_ecr.repository_url
}