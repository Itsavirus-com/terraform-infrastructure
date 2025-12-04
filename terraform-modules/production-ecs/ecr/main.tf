resource "aws_ecr_repository" "repository" {
    name = "${var.PROJECT}-repository"


    image_scanning_configuration {
        scan_on_push = true
    }
    encryption_configuration {
        encryption_type = "KMS"
    }
}