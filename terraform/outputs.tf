output "vpc_id" {
  value = module.vpc.vpc_id
}

output "mongo_public_ip" {
  value = aws_instance.mongo_vm.public_ip
}

output "backup_bucket" {
  value = aws_s3_bucket.mongo_backups.bucket
}