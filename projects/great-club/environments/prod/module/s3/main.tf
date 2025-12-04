# # Customer managed KMS key
# resource "aws_kms_key" "kms_s3_key" {
#     description             = "Key to protect S3 objects"
#     key_usage               = "ENCRYPT_DECRYPT"
#     deletion_window_in_days = 7
#     is_enabled              = true
# }

# resource "aws_kms_alias" "kms_s3_key_alias" {
#     name          = "alias/${var.PROJECT}-s3-key"
#     target_key_id = aws_kms_key.kms_s3_key.key_id
# }

# # Bucket creation
# resource "aws_s3_bucket" "protected_bucket" {
#   bucket = "${var.PROJECT}-envs"
# }

# # # Log bucket creation
# # resource "aws_s3_bucket" "log_bucket" {
# #   bucket = "${var.PROJECT}-${var.S3_BUCKET_LOG_NAME}"
# # }

# # # Bucket private access
# resource "aws_s3_bucket_acl" "protected_bucket_acl" {
#   bucket = aws_s3_bucket.protected_bucket.id
#   acl    = "private"
# }

# # # Log buckeprivate access
# # resource "aws_s3_bucket_acl" "log_bucket_acl" {
# #   bucket = aws_s3_bucket.log_bucket.id
# #   acl    = "log-delivery-write"
# # }

# # # Enable bucket versioning
# resource "aws_s3_bucket_versioning" "protected_bucket_versioning" {
#   bucket = aws_s3_bucket.protected_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # # Enable server access logging
# # resource "aws_s3_bucket_logging" "protected_bucket_logging" {
# #   bucket = aws_s3_bucket.protected_bucket.id

# #   target_bucket = aws_s3_bucket.log_bucket.id
# #   target_prefix = "${var.PROJECT}-bucket/"
# # }

# # # Enable default Server Side Encryption
# resource "aws_s3_bucket_server_side_encryption_configuration" "protected_bucket_server_side_encryption" {
#   bucket = aws_s3_bucket.protected_bucket.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#         kms_master_key_id = aws_kms_key.kms_s3_key.arn
#         sse_algorithm     = "aws:kms"
#     }
#   }
# }

# # # Creating Lifecycle Rule
# # resource "aws_s3_bucket_lifecycle_configuration" "protected_bucket_lifecycle_rule" {
# #   # Must have bucket versioning enabled first
# #   depends_on = [aws_s3_bucket_versioning.protected_bucket_versioning]

# #   bucket = aws_s3_bucket.protected_bucket.bucket

# #   rule {
# #     id = "basic_config"
# #     status = "Enabled"

# #     filter {
# #       prefix = "config/"
# #     }

# #     noncurrent_version_transition {
# #       noncurrent_days = 30
# #       storage_class   = "STANDARD_IA"
# #     }

# #     noncurrent_version_transition {
# #       noncurrent_days = 60
# #       storage_class   = "GLACIER"
# #     }
    
# #     noncurrent_version_expiration {
# #       noncurrent_days = 90
# #     }
# #   }
# # }

# # # Disabling bucket public access
# # resource "aws_s3_bucket_public_access_block" "protected_bucket_access" {
# #   bucket = aws_s3_bucket.protected_bucket.id

# #   # Block public access
# #   block_public_acls   = true
# #   block_public_policy = true
# #   ignore_public_acls = true
# #   restrict_public_buckets = true
# # }

# # Public S3 Bucket
# resource "aws_s3_bucket" "media_bucket" {
#   bucket = "${var.PROJECT}-medias"
# }

# # Bucket public read access
# resource "aws_s3_bucket_acl" "media_bucket_acl" {
#   bucket = aws_s3_bucket.media_bucket.id
#   acl    = "private"
# }

# # Enable bucket versioning
# resource "aws_s3_bucket_versioning" "media_bucket_versioning" {
#   bucket = aws_s3_bucket.media_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # Enable default Server Side Encryption
# resource "aws_s3_bucket_server_side_encryption_configuration" "media_bucket_server_side_encryption" {
#   bucket = aws_s3_bucket.media_bucket.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#         kms_master_key_id = aws_kms_key.kms_s3_key.arn
#         sse_algorithm     = "aws:kms"
#     }
#   }
# }

# # Disabling bucket public access
# resource "aws_s3_bucket_public_access_block" "protected_bucket_access" {
#   bucket = aws_s3_bucket.protected_bucket.id

#   # Block public access
#   block_public_acls   = false
#   block_public_policy = false
#   ignore_public_acls = false
#   restrict_public_buckets = false
# }

# Customer managed KMS key
resource "aws_kms_key" "kms_s3_key" {
    description             = "Key to protect S3 objects"
    key_usage               = "ENCRYPT_DECRYPT"
    deletion_window_in_days = 7
    is_enabled              = true
}

resource "aws_kms_alias" "kms_s3_key_alias" {
    name          = "alias/${var.PROJECT}-s3-key"
    target_key_id = aws_kms_key.kms_s3_key.key_id
}

# Bucket creation
resource "aws_s3_bucket" "protected_bucket" {
  bucket = "${var.PROJECT}-prod-envs"
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "protected_bucket_versioning" {
  bucket = aws_s3_bucket.protected_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable default Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "protected_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.protected_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_s3_key.arn
        sse_algorithm     = "aws:kms"
    }
  }
}

# Public S3 Bucket
resource "aws_s3_bucket" "media_bucket" {
  bucket = "${var.PROJECT}-medias"
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "media_bucket_versioning" {
  bucket = aws_s3_bucket.media_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable default Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "media_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.media_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_s3_key.arn
        sse_algorithm     = "aws:kms"
    }
  }
}

# Disabling bucket public access
resource "aws_s3_bucket_public_access_block" "protected_bucket_access" {
  bucket = aws_s3_bucket.protected_bucket.id

  # Block public access
  block_public_acls         = false
  block_public_policy       = false
  ignore_public_acls        = false
  restrict_public_buckets   = false
}
