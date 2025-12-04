output "cron_ecr_url" {
  value = aws_ecr_repository.cron_ecr.repository_url
}