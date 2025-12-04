module "vnet" {
    source = "../../terraform-modules/staging/vnet"

    PROJECT = var.PROJECT
    AVAILABILITY_ZONE = var.AVAILABILITY_ZONE
    VPC_CIDR = var.VPC_CIDR
    PUBLIC_SUBNETS_CIDR = var.PUBLIC_SUBNETS_CIDR
    ALLOWED_IP = var.ALLOWED_IP
}

module "s3" {
    source = "../../terraform-modules/production-ecs/s3"

    PROJECT = var.PROJECT
    S3_BUCKET_NAME = var.S3_BUCKET_NAME
    S3_BUCKET_LOG_NAME = var.S3_BUCKET_LOG_NAME
}

module "rds" {
    source = "../../../terraform-modules/production-ecs/rds"
    private_subnet_1_id = module.vnet.private_subnet_1_id
    private_subnet_2_id = module.vnet.private_subnet_2_id
    ecs_sg_id = module.vnet.ecs_security_group_id
    db_sg_id = module.vnet.db_security_group_id
    db_password = var.db_password
    PROJECT = var.PROJECT
    DB_INSTANCE_TYPE = var.DB_INSTANCE_TYPE
}
