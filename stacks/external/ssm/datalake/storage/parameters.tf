locals {
  env = {
    default = {
      assets_bucket_id = try(jsondecode(data.aws_ssm_parameter.storage.insecure_value).assets_bucket_id, null)
      bronce_bucket_id = try(jsondecode(data.aws_ssm_parameter.storage.insecure_value).bronce_bucket_id, null)
      silver_bucket_id = try(jsondecode(data.aws_ssm_parameter.storage.insecure_value).silver_bucket_id, null)
      gold_bucket_id   = try(jsondecode(data.aws_ssm_parameter.storage.insecure_value).gold_bucket_id, null)
    }
    dev = {

    }
    qa = {

    }
    prd = {

    }
  }
  # Set workspace parameters for the associated environment
  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
