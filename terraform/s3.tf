resource "aws_s3_bucket" "mongo_backups" {
  bucket = "wiz-mongo-backups-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Intentional weakness required by assignment
resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.mongo_backups.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {

  bucket = aws_s3_bucket.mongo_backups.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.mongo_backups.arn,
        "${aws_s3_bucket.mongo_backups.arn}/*"
      ]
    }]
  })
}