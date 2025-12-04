variable "PROJECT" {
  type = string
}
variable "VPC_CIDR" {
  type = string
}
variable "AVAILABILITY_ZONE" {
  type = list(string)
}
variable "PUBLIC_SUBNETS_CIDR" {
  type = list(string)
}
variable "PRIVATE_SUBNETS_CIDR" {
  type = list(string)
}