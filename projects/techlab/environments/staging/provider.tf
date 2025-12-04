provider "aws" {
    region = var.AWS_REGION
    shared_config_files = ["~/.aws/config"]
    shared_credentials_files = ["~/.aws/credentials"]
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