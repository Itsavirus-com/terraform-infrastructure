output "app_ecr_url" {
  value = aws_ecr_repository.app_ecr.repository_url
}