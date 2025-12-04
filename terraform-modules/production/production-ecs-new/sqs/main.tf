resource "aws_sqs_queue" "email_queue" {
  name = "${var.PROJECT}-poduction-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds = 345600
}