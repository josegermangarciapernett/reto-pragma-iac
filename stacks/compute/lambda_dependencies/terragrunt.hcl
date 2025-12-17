include "root" {
  path = find_in_parent_folders()
}

dependency "datalake_security" {
  config_path = "${get_parent_terragrunt_dir("root")}/stacks/external/ssm/datalake/security"
  mock_outputs = {
    storage_key_arn = "arn:aws:kms:us-east-1:12345678912:key/fd018b93-04ba-4917-9365-f6f6167150bc"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  storage_key_arn = dependency.datalake_security.outputs.storage_key_arn
}