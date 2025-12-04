output "frontend_ecr_url" {
  value = aws_ecr_repository.frontend_ecr.repository_url
}