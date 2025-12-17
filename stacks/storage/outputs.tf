#############################################################################
# cert_bucket Module
#############################################################################
output "cert_bucket_id" {
  description = "The name of the bucket."
  value       = module.cert_bucket.s3_bucket_id
}

output "cert_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.cert_bucket.s3_bucket_arn
}
