terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state configuration (commented out - using local state)
  # backend "s3" {
  #   bucket         = "mobypark-terraform-state"
  #   key            = "production/terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "mobypark-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile != "" ? var.aws_profile : null
  
  # Use credentials only if profile is not specified
  access_key = var.aws_profile == "" ? var.access_key : null
  secret_key = var.aws_profile == "" ? var.secret_key : null

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Client      = "MobyPark"
      ManagedBy   = "terraform"
    }
  }
} 