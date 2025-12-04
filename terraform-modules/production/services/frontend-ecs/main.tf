resource "aws_ecs_task_definition" "app_task" {
  family = "${var.FRONTEND}-task-def"
  execution_role_arn = "${aws_iam_role.ecsTaskRoleWithS3Access.arn}"
  task_role_arn = "${aws_iam_role.ecsTaskRoleWithS3Access.arn}"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name = "${var.FRONTEND}-api-service",
      image = "${frontend_ecr.repository_url}:latest",
      environmentFiles = [
        {
          value = "${var.env_s3_arn}/frontendproduction.env",
          type = "s3"
        }
      ],
      essential = true,
      portMappings = [
        {
          protocol = "tcp",
          containerPort = 8000,
          hostPort = 0
        }
      ],
      memory = 512,
      cpu = 256,
      compatibilities = ["EC2"],
      logConfiguration = {
        logDriver = "awslogs",
        secretOptions = null,
        options = {
          awslogs-group = "/ecs/${var.FRONTEND}-log-group",
          awslogs-region = var.REGION,
          awslogs-stream-prefix = "ecs"
        }
      },
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = "${var.FRONTEND}-service"     # Name the service
  cluster         = "${var.cluster_id}"   # Reference the created Cluster
  task_definition = "${aws_ecs_task_definition.app_task.arn}" # Reference the task that the service will spin up
  launch_type     = "EC2"
  desired_count   = 2 # Set up the number of containers to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # Reference the target group
    container_name   = "${var.FRONTEND}-service"
    container_port   = 80 # Specify the container port
  }
}

resource "aws_ecr_repository" "frontend_ecr" {
    name = "${var.FRONTEND}-repository"


    image_scanning_configuration {
        scan_on_push = true
    }
    encryption_configuration {
        encryption_type = "KMS"
    }
}

resource "aws_lb_target_group" "target_group" {
  name = "${var.FRONTEND}-lb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${var.lb_arn}" #  load balancer
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # target group
  }
}

resource "aws_cloudwatch_log_group" "ecs_service_log_group" {
  name = "/ecs/${var.FRONTEND}-log-group"
  retention_in_days = 7

  tags = {
    Environment = "production",
    Application = "${var.FRONTEND}"
  }
}