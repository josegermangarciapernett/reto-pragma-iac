/**
* # Stack for deploying Glue Connections resources
* Below is information on the modules and resources
* ## Modules info
* - [terraform-aws-modules/ssm-parameter/aws](https://github.com/terraform-aws-modules/terraform-aws-ssm-parameter): Version 1.1.0
* - [cloudposse/glue/aws//modules/glue-connection](https://github.com/cloudposse/terraform-aws-glue): Version 0.4.0
*
*/

module "ssm_ps_connections" {
  source = "terraform-aws-modules/ssm-parameter/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "1.1.0"

  for_each = local.workspace["connection_destinations"]

  create               = each.value.create
  name                 = each.value.name
  description          = each.value.description
  value                = "[]"
  ignore_value_changes = true

  tags = local.workspace["tags"]
}

module "glue_connections" {
  source = "cloudposse/glue/aws//modules/glue-connection"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "0.4.0"

  for_each = { for connection_name in try(local.workspace["used_connections"], []) :
  connection_name => try(local.workspace[connection_name], {}) }

  enabled                = each.value.create
  connection_name        = each.value.connection_name
  connection_description = each.value.connection_description
  connection_type        = each.value.connection_type
  connection_properties  = each.value.connection_properties

  physical_connection_requirements = each.value.physical_connection_requirements

  tags = local.workspace["tags"]
}
