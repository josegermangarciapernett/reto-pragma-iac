output "assets_bucket_id" {
  description = "The name of the bucket."
  value       = local.workspace["assets_bucket_id"]
}

output "bronce_bucket_id" {
  description = "The name of the bucket."
  value       = local.workspace["bronce_bucket_id"]
}

output "silver_bucket_id" {
  description = "The name of the bucket."
  value       = local.workspace["silver_bucket_id"]
}

output "gold_bucket_id" {
  description = "The name of the bucket."
  value       = local.workspace["gold_bucket_id"]
}
