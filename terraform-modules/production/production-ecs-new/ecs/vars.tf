variable "PROJECT" {
    type = string
}

variable "AMI" {
    type = string
}

variable "INSTANCE_TYPE" {
    type = string
}

variable "EBS_VOLUME_SIZE" {
    type = string
}

variable "REGION" {
    type = string
}

variable "env_s3_arn" {
    type = string
}

variable "ecs_iam_policy_arn" {
    type = list(string)
}

variable "ecs_sg_id" {
    type = string
}

variable "public_subnet_id" {
    type = string
}

variable "private_subnet_1_id" {
    type = string
}

variable "private_subnet_2_id" {
    type = string
}