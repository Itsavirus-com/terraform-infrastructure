variable "PROJECT" {
    type = string
}

variable "DB_INSTANCE_TYPE" {
    type = string
}

variable "db_password" {
    type = string
    sensitive = true
}

variable "private_subnet_1_id" {
    type = string
}

variable "private_subnet_2_id" {
    type = string
}

variable "db_sg_id" {
    type = string
}

variable "ecs_sg_id" {
    type = string
}