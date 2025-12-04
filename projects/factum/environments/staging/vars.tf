variable "access_key" {
    description = "Access key to AWS console"
}

variable "secret_key" {
    description = "Secret key to AWS console"
}

variable "AWS_REGION" {
    default = "ap-southeast-1"
}

variable "PROJECT" {
    default = "factum-staging"
}

variable "URL" {
    default = "staging.factum.com"
}

variable "AVAILABILITY_ZONE" {
    default = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "VPC_CIDR" {
    default = "10.0.0.0/16"
}
variable "PUBLIC_SUBNETS_CIDR" {
    default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "AMI" {
    default = "ami-0df7a207adb9748c7"
}

variable "INSTANCE_TYPE" {
    default = "t3.medium"
}

variable "EBS_VOLUME_SIZE" {
    default = "100"
}

variable "S3_BUCKET_NAME" {
    // with ${var.PROJECT} as prefix
    default = "bucket"
}
variable "S3_BUCKET_LOG_NAME" {
    // with ${var.PROJECT} as prefix
    default = "log-bucket-2"
}
variable "ALLOWED_IP" {
    # IAV Office's IP
    default = ["202.58.195.12/32"]
    description = "allowed ip for private access"
}