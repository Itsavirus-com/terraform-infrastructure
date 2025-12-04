resource "aws_lightsail_key_pair" "my_key" {
  name       = "${var.PROJECT}-user"
  public_key = file(pathexpand("../../../key-pairs/publickey"))
}

# Create a new Lightsail instance
resource "aws_lightsail_instance" "instance" {
  name              = "${var.PROJECT}-instance"
  availability_zone = var.AVAILABILITY_ZONE  # Replace with your desired availability zone
  blueprint_id      = var.BLUEPRINT_ID  # Replace with your desired blueprint ID
  bundle_id         = var.BUNDLE_ID  # Replace with your desired bundle ID
  key_pair_name     = aws_lightsail_key_pair.my_key.name  # Replace with your desired key pair name
}

# Allocate a static IP for the instance
resource "aws_lightsail_static_ip" "instance_eip" {
  name = "${var.PROJECT}-static-ip"
}

# Attach the static IP to the instance
resource "aws_lightsail_static_ip_attachment" "instance_eip_attachment" {
  static_ip_name    = aws_lightsail_static_ip.instance_eip.name
  instance_name     = aws_lightsail_instance.instance.name
}

resource "aws_lightsail_instance_public_ports" "vps" {
  instance_name = aws_lightsail_instance.instance.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }
  port_info {
    protocol  = "tcp"
    from_port = 25
    to_port   = 25
  }
  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }
  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  } 
  port_info {
    protocol      = "tcp"
    from_port     = 3000
    to_port       = 3000
  }
  port_info {
    protocol      = "tcp"
    from_port     = 996
    to_port       = 996
  }
  port_info {
    protocol      = "udp"
    from_port     = 7946
    to_port       = 7946
  }
  port_info {
    protocol      = "udp"
    from_port     = 4789
    to_port       = 4789
  }
  port_info {
    protocol      = "udp"
    from_port     = 2377
    to_port       = 2377
  }
  port_info {
    protocol      = "tcp"
    from_port     = 5432
    to_port       = 5432
    cidrs         = var.ALLOWED_IP
  }
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "${var.PROJECT}-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "example_bucket_policy" {
  bucket = aws_s3_bucket.example_bucket.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.example_bucket.id}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.example_bucket.id
  acl    = "private"
}




# Create an SQS queue
resource "aws_sqs_queue" "example_queue" {
  name = "${var.PROJECT}-queue"
}

# Attach a queue policy to allow all actions
resource "aws_sqs_queue_policy" "example_queue_policy" {
  queue_url = aws_sqs_queue.example_queue.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowAllActions",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "sqs:*",
        "Resource": aws_sqs_queue.example_queue.arn
      }
    ]
  })
}

# Create an IAM role for EC2 instance
resource "aws_iam_role" "example_role" {
  name = "example-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

# Create an IAM policy with necessary permissions
resource "aws_iam_policy" "example_policy" {
  name        = "example-policy"
  description = "Example IAM policy for EC2"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "sqs:*",
          "s3:*"
        ],
        "Resource": "*"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.example_policy.arn
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "example_instance_profile" {
  name = "example-instance-profile"
  role = aws_iam_role.example_role.name
}


