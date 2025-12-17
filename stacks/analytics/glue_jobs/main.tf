/**
* # Stack for deploying Glue Jobs resources
* Below is information on the modules and resources
* ## Modules info
* - [terraform-aws-modules/iam/aws//modules/iam-assumable-role](https://github.com/terraform-aws-modules/terraform-aws-iam): Version 5.44.1
* - [cloudposse/glue/aws//modules/glue-crawler](https://github.com/cloudposse/terraform-aws-glue): Version 0.4.0
*
*/

module "job_iam_roles" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "5.44.1"

  for_each = local.workspace["job_roles"]

  create_role                       = each.value.create_role
  role_name                         = each.value.role_name
  role_requires_mfa                 = each.value.role_requires_mfa
  trusted_role_services             = each.value.trusted_role_services
  inline_policy_statements          = local.workspace["inline_policies"][each.value.inline_policy]
  custom_role_policy_arns           = each.value.custom_role_policy_arns
  number_of_custom_role_policy_arns = length(each.value.custom_role_policy_arns)

  tags = local.workspace["tags"]
}

module "glue_jobs" {
  source = "cloudposse/glue/aws//modules/glue-job"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "0.4.0"

  for_each = { for job_name in try(local.workspace["used_jobs"], []) :
  job_name => try(local.workspace[job_name], {}) }

  enabled           = each.value.create
  job_name          = each.value.job_name
  job_description   = each.value.job_description
  role_arn          = module.job_iam_roles[each.value.role].iam_role_arn
  glue_version      = each.value.glue_version
  default_arguments = each.value.default_arguments

  worker_type        = each.value.worker_type
  number_of_workers  = each.value.number_of_workers
  max_retries        = each.value.max_retries
  timeout            = each.value.timeout
  command            = each.value.command
  execution_property = each.value.execution_property

  connections = [
    for connection_name in try(local.workspace["job_connections"][each.key], []) :
    var.glue_connection_names[connection_name]
    if contains(keys(var.glue_connection_names), connection_name)
  ]

  tags = local.workspace["tags"]
}
