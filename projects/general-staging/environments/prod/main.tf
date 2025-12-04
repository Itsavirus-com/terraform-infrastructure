module "vnet" {
    source = "../../../terraform-modules/vnet"

    PROJECT = var.PROJECT
    AVAILABILITY_ZONE = var.AVAILABILITY_ZONE
    VPC_CIDR = var.VPC_CIDR
    PUBLIC_SUBNETS_CIDR = var.PUBLIC_SUBNETS_CIDR
    ALLOWED_IP = var.ALLOWED_IP
}

module "ec2" {
    source = "../../../terraform-modules/ec2"
    public_subnet_id = module.vnet.public_subnet_id
    sg_id = module.vnet.sg_id

    PROJECT = var.PROJECT
    AMI = var.AMI
    AVAILABILITY_ZONE = var.AVAILABILITY_ZONE
    INSTANCE_TYPE = var.INSTANCE_TYPE
    EBS_VOLUME_SIZE = var.EBS_VOLUME_SIZE
}