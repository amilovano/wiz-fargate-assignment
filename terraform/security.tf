resource "aws_cloudtrail" "main" {
  name                          = "wiz-trail"
  s3_bucket_name                = aws_s3_bucket.mongo_backups.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}