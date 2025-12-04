resource "aws_cloudwatch_log_group" "ecs_service_log_group" {
  name = "/ecs/${var.PROJECT}-log-group"
  retention_in_days = 7

  tags = {
    Environment = "production",
    Application = "${var.PROJECT}"
  }
}