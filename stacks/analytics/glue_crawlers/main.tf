/**
* # Stack for deploying Glue Crawler resources
* Below is information on the modules and resources
* ## Modules info
* - [terraform-aws-modules/iam/aws//modules/iam-assumable-role](https://github.com/terraform-aws-modules/terraform-aws-iam): Version 5.44.1
* - [cloudposse/glue/aws//modules/glue-crawler](https://github.com/cloudposse/terraform-aws-glue): Version 0.4.0
*
*/

module "crawler_iam_roles" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "5.44.1"

  for_each = local.workspace["crawler_roles"]

  create_role                       = each.value.create_role
  role_name                         = each.value.role_name
  role_requires_mfa                 = each.value.role_requires_mfa
  trusted_role_services             = each.value.trusted_role_services
  inline_policy_statements          = local.workspace["inline_policies"][each.value.inline_policy]
  custom_role_policy_arns           = each.value.custom_role_policy_arns
  number_of_custom_role_policy_arns = length(each.value.custom_role_policy_arns)

  tags = local.workspace["tags"]
}

module "glue_crawlers" {
  source = "cloudposse/glue/aws//modules/glue-crawler"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "0.4.0"

  for_each = { for crawler_name in try(local.workspace["used_crawlers"], []) :
  crawler_name => try(local.workspace[crawler_name], {}) }

  enabled               = each.value.create
  crawler_name          = each.value.crawler_name
  crawler_description   = each.value.crawler_description
  database_name         = each.value.database
  role                  = module.crawler_iam_roles[each.value.role].iam_role_arn
  schedule              = each.value.schedule
  table_prefix          = each.value.table_prefix
  configuration         = each.value.configuration
  recrawl_policy        = each.value.recrawl_policy
  schema_change_policy  = each.value.schema_change_policy
  lineage_configuration = each.value.lineage_configuration
  s3_target             = each.value.s3_target

  tags = local.workspace["tags"]
}
