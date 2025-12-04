provider "aws" {
    region = var.AWS_REGION
    shared_config_files = ["~/.aws/config"]
    shared_credentials_files = ["~/.aws/credentials"]
}
