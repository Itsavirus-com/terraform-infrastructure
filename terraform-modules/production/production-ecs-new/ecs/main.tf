# IAM role for ecs execution role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com", "ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskRoleWithS3Access" {
  name               = "ecsTaskRoleWithS3Access"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecsTaskRoleWithS3Access_policy" {
  role       = "${aws_iam_role.ecsTaskRoleWithS3Access.name}"
  count = "${length(var.ecs_iam_policy_arn)}"
  policy_arn = "${var.ecs_iam_policy_arn[count.index]}"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceRole-${aws_ecs_cluster.cluster.name}"
  path = "/"
  role = aws_iam_role.ecsTaskRoleWithS3Access.name
}

# ECS Autoscaling Group
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

# resource "aws_launch_configuration" "ecs_launch_config" {
#     name_prefix          = "${var.PROJECT}-ec2"
#     image_id             = "${data.aws_ami.ecs_ami.image_id}"
#     iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
#     security_groups      = [var.ecs_sg_id]
#     user_data            = data.template_file.user_data.rendered
#     instance_type        = var.INSTANCE_TYPE
#     associate_public_ip_address = true

#     root_block_device {
#         volume_type = "gp2"
#         volume_size = "20"
#         delete_on_termination = true
#     }

#     ebs_block_device {
#       device_name = "/dev/sda2"
#       volume_size = var.EBS_VOLUME_SIZE
#       encrypted   = true
#     }
# }

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.tpl")

  vars = {
    cluster_name = aws_ecs_cluster.cluster.name
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
    name                      = "${var.PROJECT}-asg"
    vpc_zone_identifier       = [var.public_subnet_id]
    launch_template {
        id      = aws_launch_template.ecs_launch_template.id
        version = "$Latest" 
    }

    desired_capacity          = 1
    min_size                  = 1
    max_size                  = 3
    health_check_grace_period = 300
    health_check_type         = "EC2"

    tag {
        key                 = "Name"
        value               = "${var.PROJECT}-ecs-instance"
        propagate_at_launch = true
    }
}

# ECS Cluster Creation
resource "aws_ecs_cluster" "cluster" {
    name = "${var.PROJECT}-production-cluster"


    tags = {
        Name = "${var.PROJECT}-production-cluster"
    }
}

resource "aws_launch_template" "ecs_launch_template" {
    name_prefix = "${var.PROJECT}-ec2"

    image_id             = "${data.aws_ami.ecs_ami.image_id}"
    instance_type        = var.INSTANCE_TYPE

    iam_instance_profile {
        arn = aws_iam_instance_profile.ecs_instance_profile.arn
    }

    block_device_mappings {
        device_name = "/dev/sda1"
        ebs {
            volume_size = 20
            volume_type = "gp2"
            delete_on_termination = true
            encrypted = false 
        }
    }

    block_device_mappings {
        device_name = "/dev/sda2"
        ebs {
            volume_size = var.EBS_VOLUME_SIZE
            encrypted = true
        }
    }

}