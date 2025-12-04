variable "access_key" {
    description = "Access key to AWS console"
}

variable "secret_key" {
    description = "Secret key to AWS console"
}

variable "db_password" {
    type = string
    sensitive = true
}

variable "AWS_REGION" {
    default = "ap-southeast-1"
}

variable "PROJECT" {
    default = "obrien-prod"
}

variable "URL" {
    default = "obrien.iavtest.com"
}

variable "AVAILABILITY_ZONE" {
    default = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "VPC_CIDR" {
    default = "10.0.0.0/16"
}
variable "PUBLIC_SUBNETS_CIDR" {
    default = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "PRIVATE_SUBNETS_CIDR" {
    default = ["10.0.128.0/20", "10.0.144.0/20"]
}
variable "AMI" {
    default = "ami-0c9b6758e5d5a9558"
}

variable "INSTANCE_TYPE" {
    default = "t3.small"
}

variable "DB_INSTANCE_TYPE" {
    default = "db.t3.small"
}

variable "EBS_VOLUME_SIZE" {
    default = "200"
}
variable "S3_BUCKET_NAME" {
    // with ${var.PROJECT} as prefix
    default = "bucket"
}
variable "S3_BUCKET_LOG_NAME" {
    // with ${var.PROJECT} as prefix
    default = "log-bucket"
}
variable "ALLOWED_IP" {
    # IAV Office's IP
    default = ["202.58.195.12/32"]
    description = "allowed ip for private access"
}
variable "ECS_IAM_POLICY_ARN" {
    default = [
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    ]
}

variable "ENV_S3_ARN" {
    default = "arn:aws:s3:::obrien-testing-envs"
}