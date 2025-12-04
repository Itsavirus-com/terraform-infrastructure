# ECS Task Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  count = var.create_ecs_execution_role ? 1 : 0

  name = "${var.name_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-execution-role"
    Type = "ExecutionRole"
  })
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  count = var.create_ecs_execution_role ? 1 : 0

  role       = aws_iam_role.ecs_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy for S3 environment files and secrets
resource "aws_iam_role_policy" "ecs_execution_additional_policy" {
  count = var.create_ecs_execution_role && (var.enable_s3_env_files || var.enable_secrets_manager || var.enable_ssm_parameters) ? 1 : 0

  name = "${var.name_prefix}-ecs-execution-additional-policy"
  role = aws_iam_role.ecs_execution_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      var.enable_s3_env_files ? [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject"
          ]
          Resource = var.s3_env_files_arns
        }
      ] : [],
      var.enable_secrets_manager ? [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = var.secrets_manager_arns
        }
      ] : [],
      var.enable_ssm_parameters ? [
        {
          Effect = "Allow"
          Action = [
            "ssm:GetParameters",
            "ssm:GetParameter"
          ]
          Resource = var.ssm_parameter_arns
        }
      ] : []
    )
  })
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  count = var.create_ecs_task_role ? 1 : 0

  name = "${var.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecs-task-role"
    Type = "TaskRole"
  })
}

# Custom policy for ECS task role
resource "aws_iam_role_policy" "ecs_task_custom_policy" {
  count = var.create_ecs_task_role && length(var.task_role_policy_statements) > 0 ? 1 : 0

  name = "${var.name_prefix}-ecs-task-custom-policy"
  role = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = var.task_role_policy_statements
  })
}

# Attach additional managed policies to task role
resource "aws_iam_role_policy_attachment" "ecs_task_role_additional_policies" {
  count = var.create_ecs_task_role ? length(var.task_role_managed_policies) : 0

  role       = aws_iam_role.ecs_task_role[0].name
  policy_arn = var.task_role_managed_policies[count.index]
}

# S3 access policy for task role (commonly needed)
resource "aws_iam_role_policy" "ecs_task_s3_policy" {
  count = var.create_ecs_task_role && var.enable_task_s3_access ? 1 : 0

  name = "${var.name_prefix}-ecs-task-s3-policy"
  role = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = concat(
          var.s3_bucket_arns,
          [for arn in var.s3_bucket_arns : "${arn}/*"]
        )
      }
    ]
  })
}

# CloudWatch Logs policy for task role
resource "aws_iam_role_policy" "ecs_task_cloudwatch_policy" {
  count = var.create_ecs_task_role && var.enable_task_cloudwatch_access ? 1 : 0

  name = "${var.name_prefix}-ecs-task-cloudwatch-policy"
  role = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# SES policy for task role (for sending emails)
resource "aws_iam_role_policy" "ecs_task_ses_policy" {
  count = var.create_ecs_task_role && var.enable_task_ses_access ? 1 : 0

  name = "${var.name_prefix}-ecs-task-ses-policy"
  role = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# SQS policy for task role
resource "aws_iam_role_policy" "ecs_task_sqs_policy" {
  count = var.create_ecs_task_role && var.enable_task_sqs_access ? 1 : 0

  name = "${var.name_prefix}-ecs-task-sqs-policy"
  role = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arns
      }
    ]
  })
} 