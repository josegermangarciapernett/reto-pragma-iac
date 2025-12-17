#############################################################################
# storage_kms Module
#############################################################################
output "jdbc_secret_ids" {
  description = "Map with the IDs of the database credential secrets"
  value       = { for secret_key, secret in try(module.jdbc_secret_manager, {}) : secret_key => secret.secret_id }
}