output "infra_key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = local.workspace["infra_key_arn"]
}

output "storage_key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = local.workspace["storage_key_arn"]
}
