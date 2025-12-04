variable "AWS_REGION" {
    default = "ap-southeast-2"
}

variable "PROJECT" {
    default = "environtment-staging"
}

variable "URL" {
    default = "staging.iavtest.com"
}

variable "AVAILABILITY_ZONE" {
    default = "ap-southeast-2a"
}

variable "VPC_CIDR" {
    default = "10.0.0.0/16"
}
variable "PUBLIC_SUBNETS_CIDR" {
    default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "AMI" {
    default = "ami-0c9b6758e5d5a9558"
}


variable "EBS_VOLUME_SIZE" {
    default = "200"
}

variable "BUNDLE_ID"{
    default = "medium_2_2"
}

variable "BLUEPRINT_ID"{
    default = "ubuntu_20_04"
}


variable "ALLOWED_IP" {
    # IAV Office's IP
    default = ["202.58.195.12/32"]
    description = "allowed ip for private access"
}