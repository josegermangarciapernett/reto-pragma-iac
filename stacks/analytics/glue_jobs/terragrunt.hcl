include "root" {
  path = find_in_parent_folders()
}

dependency "datalake_security" {
  config_path = "${get_parent_terragrunt_dir("root")}/stacks/external/ssm/datalake/security"
  mock_outputs = {
    storage_key_arn = "arn:aws:kms:us-east-1:012345678912:key/fd018b93-04ba-4917-9365-f6f6167150bc"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "datalake_networking" {
  config_path = "${get_parent_terragrunt_dir("root")}/stacks/external/ssm/datalake/networking"
  mock_outputs = {
    private_azs = ["us-east-1a", "us-east-1a"]
    private_subnet_ids = [
      "subnet-082b2836a05d3d363",
      "subnet-082b2836a05d3d363"
    ]
    glue_connection_sg_id = "sg-037aece3b3e44bf0f"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
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

dependency "security" {
  config_path = "${get_parent_terragrunt_dir("root")}/stacks/security"
  mock_outputs = {
    jdbc_secret_ids = {
      "alfaprd-dev" = "arn:aws:secretsmanager:us-east-1:012345678912:secret:/datalake/dev/alfaprd-dev-xxxxxx"
      "alfaprd-qa" = "arn:aws:secretsmanager:us-east-1:012345678912:secret:/datalake/dev/alfaprd-qa-xxxxxx"
      "alfaprd-cer" = "arn:aws:secretsmanager:us-east-1:012345678912:secret:/datalake/dev/alfaprd-qa-xxxxxx"
      "alfaprd-prd" = "arn:aws:secretsmanager:us-east-1:012345678912:secret:/datalake/dev/alfaprd-qa-xxxxxx"
      "alfacomp-dev" = "arn:aws:secretsmanager:us-east-1:012345678912:secret:/datalake/dev/alfacomp-dev-xxxxxx"
      "alfacomp-qa" = "arn:aws:secretsmanager:us-east-1:012345678912:secret:/datalake/dev/alfacomp-dev-xxxxxx"
      "alfacomp-prd" = "arn:aws:secretsmanager:us-east-1:012345678912:secret:/datalake/dev/alfacomp-dev-xxxxxx"
    }
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "glue_connections" {
  config_path = "${get_parent_terragrunt_dir("root")}/stacks/analytics/glue_connections"
  mock_outputs = {
    connection_names = {
      connection_alfaprd_dev = "datalake-dev-alfaprd-dev-connection"
      connection_alfaprd_qa  = "datalake-dev-alfaprd-qa-connection"
      connection_alfaprd_cer = "datalake-dev-alfaprd-cer-connection"
      connection_alfaprd_prd = "datalake-dev-alfaprd-cer-connection"
    }
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  storage_kms_key_arn   = dependency.datalake_security.outputs.storage_key_arn
  private_azs           = dependency.datalake_networking.outputs.private_azs
  private_subnet_ids    = dependency.datalake_networking.outputs.private_subnet_ids
  glue_connection_sg_id = dependency.datalake_networking.outputs.glue_connection_sg_id
  assets_bucket_id      = dependency.datalake_storage.outputs.assets_bucket_id
  bronce_bucket_id      = dependency.datalake_storage.outputs.bronce_bucket_id
  silver_bucket_id      = dependency.datalake_storage.outputs.silver_bucket_id
  gold_bucket_id        = dependency.datalake_storage.outputs.gold_bucket_id
  jdbc_secret_ids       = dependency.security.outputs.jdbc_secret_ids
  glue_connection_names = dependency.glue_connections.outputs.connection_names
}
