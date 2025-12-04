resource "aws_ecr_repository" "frontend_ecr" {
    name = "${var.FRONTEND}-${var.PROJECT}-repository"


    image_scanning_configuration {
        scan_on_push = true
    }
    encryption_configuration {
        encryption_type = "KMS"
    }
}

resource "aws_ecr_repository" "backend_ecr" {
    name = "${var.BACKEND}-${var.PROJECT}-repository"


    image_scanning_configuration {
        scan_on_push = true
    }
    encryption_configuration {
        encryption_type = "KMS"
    }
}
resource "aws_ecr_repository" "cron_ecr" {
    name = "${var.CRON}-${var.PROJECT}-repository"


    image_scanning_configuration {
        scan_on_push = true
    }
    encryption_configuration {
        encryption_type = "KMS"
    }
}