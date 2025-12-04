resource "aws_db_instance" "instance" {
    identifier             = "${var.PROJECT}-db"
    allocated_storage      = 20
    max_allocated_storage  = 50
    engine                 = "postgres"
    engine_version         = "14"
    instance_class         = var.DB_INSTANCE_TYPE
    db_name                = "${var.PROJECT}"
    username               = "${var.PROJECT}"
    password               = var.db_password
    db_subnet_group_name   = aws_db_subnet_group.default.name
    vpc_security_group_ids = [var.db_sg_id, var.ecs_sg_id]
    publicly_accessible    = true
    skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "default" {
    name       = "${var.PROJECT}_db_subnet_group"
    subnet_ids = [var.private_subnet_1_id, var.private_subnet_2_id]

    tags = {
        Name = "${var.PROJECT}_db_subnet_group",
    }
}