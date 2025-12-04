resource "aws_db_instance" "instance" {
    identifier             = "${var.PROJECT}-db"
    allocated_storage      = 20
    max_allocated_storage  = 50
    engine                 = "${var.DBENGINE}"
    engine_version         = "${var.DBVERSION}"
    instance_class         = var.DB_INSTANCE_TYPE
    db_name                = "${var.PROJECT}"
    username               = "${var.DBUSERNAME}"
    password               = var.db_password
    db_subnet_group_name   = aws_db_subnet_group.prvsubnet.name
    vpc_security_group_ids = [var.db_sg_id, var.ecs_sg_id]
    publicly_accessible    = true
    skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "prvsubnet" {
    name       = "${var.PROJECT}_db_subnet_group"
    subnet_ids = [var.private_subnet_1_id, var.private_subnet_2_id]

    tags = {
        Name = "${var.PROJECT}_db_subnet_group",
    }
}