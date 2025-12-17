locals {
  env = {
    default = {
      infra_key_arn   = try(jsondecode(data.aws_ssm_parameter.security.insecure_value).infra_key_arn, null)
      storage_key_arn = try(jsondecode(data.aws_ssm_parameter.security.insecure_value).storage_key_arn, null)
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
