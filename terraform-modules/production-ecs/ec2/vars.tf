variable "public_subnet_id" {
    type = string
}
variable "sg_id" {
    type = string
}

variable "PROJECT" {
    type = string
}
variable "AMI" {
    type = string
}
variable "INSTANCE_TYPE" {
    type = string
}
variable "AVAILABILITY_ZONE" {
    type = list(string)
}
variable "EBS_VOLUME_SIZE" {
    type = string
}