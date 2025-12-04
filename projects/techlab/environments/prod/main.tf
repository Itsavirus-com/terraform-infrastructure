module "vnet" {
    source = "../../../terraform-modules/staging/vnet"

    PROJECT = var.PROJECT
    AVAILABILITY_ZONE = var.AVAILABILITY_ZONE
    VPC_CIDR = var.VPC_CIDR
    PUBLIC_SUBNETS_CIDR = var.PUBLIC_SUBNETS_CIDR
    ALLOWED_IP = var.ALLOWED_IP
}

module "ec2" {
    source = "../../../terraform-modules/staging/ec2"

    public_subnet_id = module.vnet.public_subnet_id
    sg_id = module.vnet.sg_id
    PROJECT = var.PROJECT
    AMI = var.AMI
    AVAILABILITY_ZONE = var.AVAILABILITY_ZONE
    INSTANCE_TYPE = var.INSTANCE_TYPE
    EBS_VOLUME_SIZE = var.EBS_VOLUME_SIZE
}

module "ses" {
    source = "../../../terraform-modules/staging/ses"
    URL = var.URL
}

module "s3" {
    source = "../../../terraform-modules/staging/s3"

    PROJECT = var.PROJECT
    S3_BUCKET_NAME = var.S3_BUCKET_NAME
    S3_BUCKET_LOG_NAME = var.S3_BUCKET_LOG_NAME
}
