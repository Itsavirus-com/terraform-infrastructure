
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

