resource "aws_cloudwatch_log_group" "ecs_frontend_log_group" {
  name = "/ecs/${var.PROJECT}/${var.FRONTEND}--log-group"
  retention_in_days = 7

  tags = {
    Environment = "production",
    Application = "${var.FRONTEND}"
  }
}

resource "aws_cloudwatch_log_group" "ecs_backend_log_group" {
  name = "/ecs/${var.PROJECT}/${var.BACKEND}-log-group"
  retention_in_days = 7

  tags = {
    Environment = "production",
    Application = "${var.BACKEND}"
  }
}

resource "aws_cloudwatch_log_group" "ecs_cron_log_group" {
  name = "/ecs/${var.PROJECT}/${var.CRON}-log-group"
  retention_in_days = 7

  tags = {
    Environment = "production",
    Application = "${var.CRON}"
  }
}