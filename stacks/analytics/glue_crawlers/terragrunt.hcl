include "root" {
  path = find_in_parent_folders()
}

dependency "datalake_storage" {
  config_path = "${get_parent_terragrunt_dir("root")}/stacks/external/ssm/datalake/storage"
  mock_outputs = {
    assets_bucket_id = "assets-bucket-id"
    bronce_bucket_id = "bronce_bucket_id"
    silver_bucket_id = "silver_bucket_id"
    gold_bucket_id   = "gold_bucket_id"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  assets_bucket_id = dependency.datalake_storage.outputs.assets_bucket_id
  bronce_bucket_id = dependency.datalake_storage.outputs.bronce_bucket_id
  silver_bucket_id = dependency.datalake_storage.outputs.silver_bucket_id
  gold_bucket_id   = dependency.datalake_storage.outputs.gold_bucket_id
}
