/**
* # Stack for deploying Analytics SSM Parameter Store resources
* Below is information on the modules and resources
* ## Modules info
* - [terraform-aws-modules/ssm-parameter/aws](https://github.com/terraform-aws-modules/terraform-aws-ssm-parameter): Version 1.1.0
*
*/

module "ssm_parameters" {
  source = "terraform-aws-modules/ssm-parameter/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "1.1.0"

  for_each = local.workspace["parameters"]

  create               = each.value.create
  name                 = each.value.name
  description          = each.value.description
  value                = "[]"
  ignore_value_changes = true

  tags = local.workspace["tags"]
}
