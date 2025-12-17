include "root" {
  path = find_in_parent_folders()
}

dependency "security" {
  config_path = "${get_parent_terragrunt_dir("root")}/stacks/security"
  mock_outputs = {
    storage_key_arn = "arn:aws:kms:us-east-1:216252549440:key/fd018b93-04ba-4917-9365-f6f6167150bc"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  storage_kms_key_arn = dependency.security.outputs.storage_key_arn
}
