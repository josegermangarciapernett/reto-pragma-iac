include "root" {
  path = find_in_parent_folders()
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

inputs = {
  private_azs           = dependency.datalake_networking.outputs.private_azs
  private_subnet_ids    = dependency.datalake_networking.outputs.private_subnet_ids
  glue_connection_sg_id = dependency.datalake_networking.outputs.glue_connection_sg_id
  jdbc_secret_ids       = dependency.security.outputs.jdbc_secret_ids
}
