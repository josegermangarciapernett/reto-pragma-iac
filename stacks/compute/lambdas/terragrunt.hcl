include "root" {
  path = find_in_parent_folders()
}

# dependency "security" {
#   config_path = "${get_parent_terragrunt_dir("root")}/stacks/security"
#   mock_outputs = {
#     infra_key_arn = "arn:aws:kms:us-east-1:12345678912:key/fd018b93-04ba-4917-9365-f6f6167150bc"
#   }
#   mock_outputs_merge_strategy_with_state = "shallow"
# }

# dependency "networking" {
#   config_path = "${get_parent_terragrunt_dir("root")}/stacks/networking"
#   mock_outputs = {
#     private_subnet_ids = [
#       "subnet-082b2836a05d3d363",
#       "subnet-082b2836a05d3d363",
#     ]
#     smb_lambda_sg_id = "sg-0f0b37375006d97c4"
#   }
#   mock_outputs_merge_strategy_with_state = "shallow"
# }

# dependency "storage" {
#   config_path = "${get_parent_terragrunt_dir("root")}/stacks/storage"
#   mock_outputs = {
#     assets_bucket_id   = "assets-bucket-id"
#     langding_bucket_id = "langding-bucket-id"
#   }
#   mock_outputs_merge_strategy_with_state = "shallow"
# }

inputs = {
  # infra_key_arn      = dependency.security.outputs.infra_key_arn
  # private_subnet_ids = dependency.networking.outputs.private_subnet_ids
  # smb_lambda_sg_id   = dependency.networking.outputs.smb_lambda_sg_id
  # assets_bucket_id   = dependency.storage.outputs.assets_bucket_id
  # langding_bucket_id = dependency.storage.outputs.assets_bucket_id
}