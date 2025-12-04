variable "PROJECT" {
    type = string
}
variable "BLUEPRINT_ID" {
    type = string
}
variable "BUNDLE_ID" {
    type = string
}
variable "AVAILABILITY_ZONE" {
    type = string
}
variable "EBS_VOLUME_SIZE" {
    type = string
}
variable "ALLOWED_IP" {
  type = list(string)
}