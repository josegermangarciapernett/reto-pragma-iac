locals {
  env = {
    default = {
      #############################################################################
      # Commons Parameters
      #############################################################################
      tags = {
        Environment = terraform.workspace
        Protected   = false
        Layer       = "Application"
      }
      #############################################################################
      # api_gateway Module
      #############################################################################
      create_api        = false
      api_name          = "${var.prefix}-${terraform.workspace}-pragma-api-gtw"
      create_api_domain = false
      openapi_config    = null
      definition_path   = "${path.module}/datafiles/oas_dev.json"

      api_endpoint_type        = "REGIONAL"
      private_link_target_arns = []
      stage_name               = "${terraform.workspace}"
      policy_statements        = {}

      api_logging_level        = "INFO"
      api_metrics_enabled      = true
      api_xray_tracing_enabled = true

      lambda_integrations = {}

      api_domain_name = ""
      #############################################################################      
      # wafv2_log_group Module
      #############################################################################
      create_waf_log            = false
      waf_log_name              = "aws-waf-logs-${var.prefix}-${terraform.workspace}-api"
      waf_log_kms_key_id        = null //var.kms_key_id
      waf_log_retention_in_days = 30
      #############################################################################
      # api_wafv2 Module
      #############################################################################
      create_waf         = false
      waf_name           = "${var.prefix}-${terraform.workspace}-pragma-apigateway-waf"
      waf_scope          = "REGIONAL"
      waf_default_action = "allow"
      waf_visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.prefix}-${terraform.workspace}-webaclapigateway"
        sampled_requests_enabled   = true
      }
      waf_managed_rule_group_statement_rules = [
        {
          name            = "${var.prefix}-rule-${lower("AWSManagedRulesCommonRuleSet")}-${terraform.workspace}"
          override_action = "none"
          priority        = 20

          statement = {
            name        = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
            rule_action_override = {
              SizeRestrictions_BODY = {
                action = "count"
              }
            }
          }

          visibility_config = {
            cloudwatch_metrics_enabled = true
            sampled_requests_enabled   = true
            metric_name                = "${var.prefix}-metric-${lower("AWSManagedRulesCommonRuleSet")}-${terraform.workspace}"
          }
        },
        {
          name            = "${var.prefix}-rule-${lower("AWSManagedRulesSQLiRuleSet")}-${terraform.workspace}"
          override_action = "none"
          priority        = 30

          statement = {
            name        = "AWSManagedRulesSQLiRuleSet"
            vendor_name = "AWS"
          }

          visibility_config = {
            cloudwatch_metrics_enabled = true
            sampled_requests_enabled   = true
            metric_name                = "${var.prefix}-metric-${lower("AWSManagedRulesSQLiRuleSet")}-${terraform.workspace}"
          }
        },
        {
          name            = "${var.prefix}-rule-${lower("AWSManagedRulesAmazonIpReputationList")}-${terraform.workspace}"
          override_action = "none"
          priority        = 40

          statement = {
            name        = "AWSManagedRulesAmazonIpReputationList"
            vendor_name = "AWS"
          }

          visibility_config = {
            cloudwatch_metrics_enabled = true
            sampled_requests_enabled   = true
            metric_name                = "${var.prefix}-metric-${lower("AWSManagedRulesAmazonIpReputationList")}-${terraform.workspace}"
          }
        },
        {
          name            = "${var.prefix}-rule-${lower("AWSManagedRulesAnonymousIpList")}-${terraform.workspace}"
          override_action = "none"
          priority        = 50

          statement = {
            name        = "AWSManagedRulesAnonymousIpList"
            vendor_name = "AWS"
          }

          visibility_config = {
            cloudwatch_metrics_enabled = true
            sampled_requests_enabled   = true
            metric_name                = "${var.prefix}-metric-${lower("AWSManagedRulesAnonymousIpList")}-${terraform.workspace}"
          }
        },
      ]
      size_constraint_statement_rules = [
        {
          name     = "${var.prefix}-rule-${lower("sizeconstraintstatement")}-${terraform.workspace}"
          action   = "block"
          priority = 10

          statement = {
            comparison_operator = "GT"
            size                = 1000000

            field_to_match = {
              all_query_arguments = {}
            }

            text_transformation = [
              {
                type     = "COMPRESS_WHITE_SPACE"
                priority = 1
              }
            ]
          }

          visibility_config = {
            cloudwatch_metrics_enabled = true
            sampled_requests_enabled   = true
            metric_name                = "${var.prefix}-metric-${lower("sizeconstraintstatement")}-${terraform.workspace}"
          }
        }
      ]
      api_waf_association_resource_arns = null
    }
    dev = {
      create_api     = true
      create_waf     = true
      create_waf_log = true
    }
    qa = {
      create_api     = true
      create_waf     = true
      create_waf_log = true

      definition_path = "${path.module}/datafiles/oas_qa.json"

      lambda_integrations = {
        post_login = {
          name         = "pragma-post-login"
          api_resource = "/*/GET/post_login"
          statement_id = "post_login"
        }
        certify = {
          name         = "pragma-cerfication"
          api_resource = "/*/POST/certify"
          statement_id = "certify"
        }
        not_certify = {
          name         = "pragma-cerfication"
          api_resource = "/*/POST/not_certify"
          statement_id = "not_certify"
        }
      }
    }
    prd = {
      create_api     = true
      create_waf     = true
      create_waf_log = true

      definition_path = "${path.module}/datafiles/oas_prd.json"
    }
  }
  # Set workspace parameters for the associated environment
  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
