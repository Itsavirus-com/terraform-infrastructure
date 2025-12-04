provider "aws" {
    region = var.AWS_REGION
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

terraform {
    required_version = ">= 0.12.0"
    required_providers {
        random = {
        source = "hashicorp/random"
        version = "3.4.3"
        }
    }
}