
module "instance"{
  source="../../../terraform-modules/lightsail/instance"

  PROJECT = var.PROJECT
  AVAILABILITY_ZONE = var.AVAILABILITY_ZONE
  BLUEPRINT_ID = var.BLUEPRINT_ID
  BUNDLE_ID = var.BUNDLE_ID
  EBS_VOLUME_SIZE = var.EBS_VOLUME_SIZE
  ALLOWED_IP = var.ALLOWED_IP

}
