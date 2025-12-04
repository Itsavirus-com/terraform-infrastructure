module "vnet" {
    source = "../../../terraform-modules/production-ecs/vnet"

    PROJECT = var.PROJECT
    AVAILABILITY_ZONE = var.AVAILABILITY_ZONE
    VPC_CIDR = var.VPC_CIDR
    PUBLIC_SUBNETS_CIDR = var.PUBLIC_SUBNETS_CIDR
    PRIVATE_SUBNETS_CIDR = var.PRIVATE_SUBNETS_CIDR
}

module "ecs" {
    source = "../../../terraform-modules/production-ecs/ecs"

    PROJECT = var.PROJECT
    AMI = var.AMI
    INSTANCE_TYPE = var.INSTANCE_TYPE
    EBS_VOLUME_SIZE = var.EBS_VOLUME_SIZE
    REGION = var.AWS_REGION
    repository_url = module.ecr.repository_url
    env_s3_arn = var.ENV_S3_ARN
    lb_target_group_arn = module.vnet.lb_target_group_arn
    ecs_iam_policy_arn = var.ECS_IAM_POLICY_ARN
    ecs_sg_id = module.vnet.ecs_security_group_id
    public_subnet_id = module.vnet.public_subnet_id
    private_subnet_1_id = module.vnet.private_subnet_1_id
    private_subnet_2_id = module.vnet.private_subnet_2_id
}

module "ecr" {
    source  = "../../../terraform-modules/production-ecs/ecr"

    PROJECT = var.PROJECT
}

module "cloudwatch" {
    source  = "../../../terraform-modules/production-ecs/cloudwatch"

    PROJECT = var.PROJECT
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

module "ses" {
    source = "../../../terraform-modules/production-ecs/ses"

    URL = var.URL
}

module "s3" {
    source = "../../../terraform-modules/production-ecs/s3"

    PROJECT = var.PROJECT
    S3_BUCKET_NAME = var.S3_BUCKET_NAME
    S3_BUCKET_LOG_NAME = var.S3_BUCKET_LOG_NAME
}

module "sqs" {
    source = "../../../terraform-modules/production-ecs/sqs"

    PROJECT = var.PROJECT
}