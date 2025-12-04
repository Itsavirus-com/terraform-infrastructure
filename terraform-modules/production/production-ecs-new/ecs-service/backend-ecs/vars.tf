variable "BACKEND" {
    type = string
}

variable "PROJECT" {
    type = string
}

variable "REGION" {
    type = string
}

variable "env_s3_arn" {
    type = string
}

variable "cluster_id" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "lb_arn" {
    type = string
}

variable "ecsTaskRoleWithS3Access_arn" {
    type = string
}