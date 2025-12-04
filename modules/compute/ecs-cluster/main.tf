# Data source for latest ECS optimized AMI
data "aws_ami" "ecs_optimized" {
  count = var.ami_id == "" ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = var.kms_key_id
      logging    = var.execute_command_logging

      dynamic "log_configuration" {
        for_each = var.execute_command_log_configuration != null ? [var.execute_command_log_configuration] : []
        content {
          cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
          cloud_watch_log_group_name     = log_configuration.value.cloud_watch_log_group_name
          s3_bucket_name                 = log_configuration.value.s3_bucket_name
          s3_bucket_encryption_enabled   = log_configuration.value.s3_bucket_encryption_enabled
          s3_key_prefix                  = log_configuration.value.s3_key_prefix
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cluster"
  })
}

# CloudWatch Log Group for ECS Execute Command
resource "aws_cloudwatch_log_group" "ecs_execute_command" {
  count = var.create_execute_command_log_group ? 1 : 0

  name              = "/ecs/${var.name_prefix}-execute-command"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-execute-command-logs"
  })
}

# IAM Role for ECS Instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.name_prefix}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-instance-role"
  })
}

# Attach AWS managed policy for ECS instances
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Instance Profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.name_prefix}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-instance-profile"
  })
}

# Launch Template
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "${var.name_prefix}-ecs-lt-"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.ecs_optimized[0].id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
      encrypted             = var.encrypt_root_volume
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = aws_ecs_cluster.cluster.name
    additional_user_data = var.additional_user_data
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-ecs-instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-ecs-volume"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-launch-template"
  })
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ecs_asg" {
  name               = "${var.name_prefix}-ecs-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  # Capacity Provider settings
  protect_from_scale_in = var.protect_from_scale_in

  dynamic "tag" {
    for_each = merge(var.tags, {
      Name = "${var.name_prefix}-ecs-asg"
      AmazonECSManaged = "true"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${var.name_prefix}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = var.managed_termination_protection ? "ENABLED" : "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = var.maximum_scaling_step_size
      minimum_scaling_step_size = var.minimum_scaling_step_size
      status                    = var.managed_scaling_status
      target_capacity           = var.target_capacity
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-capacity-provider"
  })
}

# Associate Capacity Provider with Cluster
resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]

  default_capacity_provider_strategy {
    base              = var.capacity_provider_base
    weight            = var.capacity_provider_weight
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
  }
} 