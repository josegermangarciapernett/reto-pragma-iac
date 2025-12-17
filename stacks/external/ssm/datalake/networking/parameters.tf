locals {
  env = {
    default = {
      vpc_id                  = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).vpc_id, null)
      public_azs              = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).public_azs, null)
      public_subnet_ids       = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).public_subnet_ids, null)
      public_route_table_ids  = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).public_route_table_ids, null)
      private_azs             = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).private_azs, null)
      private_subnet_ids      = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).private_subnet_ids, null)
      private_route_table_ids = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).private_route_table_ids, null)

      glue_connection_sg_id = try(jsondecode(data.aws_ssm_parameter.networking.insecure_value).glue_connection_sg_id, null)
      smb_lambda_sg_id      = try(jsondecode(data.aws_ssm_parameter.networking.insecure_value).smb_lambda_sg_id, null)
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
