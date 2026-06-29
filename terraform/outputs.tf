output "vpc_id" {
  value = module.vpc.vpc_id
}

output "backup_bucket" {
  value = aws_s3_bucket.mongo_backups.bucket
}