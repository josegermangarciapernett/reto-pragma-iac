/**
* # Stack for deploying Api Gateway resources
* Below is information on the modules and resources
* ## Modules info
* - [terraform-aws-api-gateway](../../../modules/terraform-aws-api-gateway): N/A
* - [terraform-aws-modules/cloudwatch/aws//modules/log-group](https://github.com/terraform-aws-modules/terraform-aws-cloudwatch): Version 4.3.0
* - [cloudposse/waf/aws](https://github.com/cloudposse/terraform-aws-waf): Version 1.3.0
*
*/

module "api_gtw" {
  source = "../../../modules/terraform-aws-api-gateway"

  create                   = local.workspace["create_api"]
  name                     = local.workspace["api_name"]
  openapi_config           = jsondecode(data.template_file.oas_definition.rendered)
  endpoint_type            = local.workspace["api_endpoint_type"]
  private_link_target_arns = local.workspace["private_link_target_arns"]
  stage_name               = local.workspace["stage_name"]
  policy_statements        = local.workspace["policy_statements"]

  logging_level        = local.workspace["api_logging_level"]
  metrics_enabled      = local.workspace["api_metrics_enabled"]
  xray_tracing_enabled = local.workspace["api_xray_tracing_enabled"]

  lambda_integrations = local.workspace["lambda_integrations"]

  tags = local.workspace["tags"]
}

module "wafv2_log_group" {
  source = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "4.3.0"

  create            = local.workspace["create_waf_log"]
  name              = local.workspace["waf_log_name"]
  kms_key_id        = local.workspace["waf_log_kms_key_id"]
  retention_in_days = local.workspace["waf_log_retention_in_days"]

  tags = local.workspace["tags"]
}

module "api_wafv2" {
  source = "cloudposse/waf/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "1.3.0"

  enabled                            = local.workspace["create_waf"]
  name                               = local.workspace["waf_name"]
  default_action                     = local.workspace["waf_default_action"]
  visibility_config                  = local.workspace["waf_visibility_config"]
  log_destination_configs            = [module.wafv2_log_group.cloudwatch_log_group_arn]
  managed_rule_group_statement_rules = local.workspace["waf_managed_rule_group_statement_rules"]
  size_constraint_statement_rules    = local.workspace["size_constraint_statement_rules"]
  association_resource_arns          = [module.api_gtw.stage_arn]

  tags = local.workspace["tags"]
}
