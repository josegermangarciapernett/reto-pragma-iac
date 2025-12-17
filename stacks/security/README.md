<!-- BEGIN_TF_DOCS -->

# Resources to Deploy Security Layer

Terraform code to provision custom resources associated with the security layer using the following Terraform modules and resources:

## Modules & Resources
### Module - infra\_kms
**Description:** KMS key to encrypt infrastructure resources
**Source Module info:**
- **Version** : "1.5.0"
- **Link**    : [terraform-aws-modules/kms/aws](github.com/terraform-aws-modules/terraform-aws-kms)
### Module - storage\_kms
**Description:** KMS key to encrypt storage resources
**Source Module info:**
- **Version** : "1.5.0"
- **Link**    : [terraform-aws-modules/kms/aws](github.com/terraform-aws-modules/terraform-aws-kms)
### Module - cognito
**Description:** KMS key to encrypt storage resources
**Source Module info:**
- **Version** : "1.0.0"
- **Link**    : [terraform-aws-cognito-user-pool](../../modules/terraform-aws-cognito-user-pool)
- **Origin**  : [lgallard/cognito-user-pool/aws](github.com/lgallard/terraform-aws-cognito-user-pool/blob/master/identity-provider.tf)
### Module acm
**Description:**
**Source Module info:**
- **Version** : "4.3.2"
- **Link**    :  [terraform-aws-modules/acm/aws](github.com/terraform-aws-modules/terraform-aws-acm)

## Code Dependencies Graph
<center>

   ![Graph](./graph.svg)

  ##### **Dependency Graph**

</center>

---

## Example parameter options for each environment

```hcl

 locals {
  env = {
    default = {
      #############################################################################
      # Commons Parameters
      #############################################################################
      tags = {
        Environment = terraform.workspace
        Layer       = "Security"
      }
      #############################################################################
      # jdbc_secrets_manager Module
      #############################################################################
      create_jdbc_secrets = false
      jdbc_secrets = {
        alfaprd_dev = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfaprd-dev"
          description             = "Secret to store JDBC connection data to alfaprd dev"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        alfaprd_qa = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfaprd-qa"
          description             = "Secret to store JDBC connection data to alfaprd qa"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        alfaprd_cer = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfaprd-cer"
          description             = "Secret to store JDBC connection data to alfaprd cer"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        alfacomp_dev = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfacomp-dev"
          description             = "Secret to store JDBC connection data to alfacomp dev"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        alfacomp_qa = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfacomp-qa"
          description             = "Secret to store JDBC connection data to alfacomp qa"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
      }
      #############################################################################
      # cognito Module
      #############################################################################
      create_cognito         = false
      user_pool_name         = "${var.prefix}-${terraform.workspace}-niif-user-pool"
      domain                 = "${var.prefix}-${terraform.workspace}-niif"
      domain_certificate_arn = null
      alias_attributes       = null
      mfa_configuration      = "OFF"
      deletion_protection    = "INACTIVE"
      string_schemas = [
        {
          attribute_data_type      = "String"
          developer_only_attribute = "false"
          mutable                  = "true"
          name                     = "email"
          required                 = "true"
          string_attribute_constraints = {
            max_length = "2048"
            min_length = "0"
          }
        },
        {
          attribute_data_type      = "String"
          developer_only_attribute = "false"
          mutable                  = "true"
          name                     = "name"
          required                 = "true"
          string_attribute_constraints = {
            max_length = "2048"
            min_length = "0"
          }
        }
      ]
      resource_server_name       = null
      resource_server_identifier = null
      resource_servers           = []

      identity_providers       = []
      clients                  = []
      auto_verified_attributes = ["email"]
      username_attributes      = ["email"]
      username_configuration = {
        case_sensitive = "false"
      }
      sms_authentication_message = "Your authentication code is {####}. "
      admin_create_user_config = {
        allow_admin_create_user_only = "false"
        email_message                = "Your username is {username} and temporary password is {####}. "
        email_subject                = "Your temporary password"
        sms_message                  = "Your username is {username} and temporary password is {####}. "
      }
      email_configuration = {
        email_sending_account = "COGNITO_DEFAULT"
      }
      password_policy = {
        minimum_length                   = "8"
        require_lowercase                = "true"
        require_numbers                  = "true"
        require_symbols                  = "true"
        require_uppercase                = "true"
        temporary_password_validity_days = "7"
      }
      recovery_mechanisms = [
        {
          name     = "verified_email"
          priority = "1"
        },
        {
          name     = "verified_phone_number"
          priority = "2"
        }
      ]
      verification_message_template = {
        default_email_option = "CONFIRM_WITH_CODE"
        email_message        = "Your verification code is {####}. "
        email_subject        = "Your verification code"
        sms_message          = "Your verification code is {####}. "
      }
      #############################################################################
      # powerbi_user Module
      #############################################################################
      create_powerbi_user                        = false
      powerbi_user_name                          = "powerBiUser"
      powerbi_user_force_destroy                 = true
      powerbi_user_password_reset_required       = false
      powerbi_user_create_iam_user_login_profile = false
      powerbi_user_create_iam_access_key         = true
      powerbi_user_param_name                    = "/${var.prefix}/${terraform.workspace}/credentials/iam-user/power-bi"
      powerbi_user_param_description             = "Parameter with power BI user CLI credentials"
      powerbi_user_policy_arns = [
        "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin",
        "arn:aws:iam::aws:policy/service-role/AWSQuicksightAthenaAccess",
      ]
    }
    dev = {
      create_cognito      = true
      create_jdbc_secrets = true

      clients = [
        {
          name                                 = "${var.prefix}-${terraform.workspace}-niif-api"
          generate_secret                      = true
          access_token_validity                = "5"
          allowed_oauth_flows                  = ["implicit"]
          allowed_oauth_flows_user_pool_client = "true"
          allowed_oauth_scopes                 = ["openid", "email", "profile"]
          auth_session_validity                = "3"
          callback_urls                        = ["https://hfoy06vw40.execute-api.us-east-1.amazonaws.com/dev/post_login", "https://53x06brwqh.execute-api.us-east-1.amazonaws.com/dev/post_login"]
          enable_token_revocation              = "false"
          explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
          id_token_validity                    = "5"
          logout_urls                          = ["https://localhost:/logout"]
          prevent_user_existence_errors        = "ENABLED"
          read_attributes                      = ["profile", "email", "email_verified", "name", "given_name", "middle_name", "family_name", "preferred_username", "phone_number"]
          refresh_token_validity               = "1"
          supported_identity_providers         = ["COGNITO"]
          token_validity_units = {
            access_token  = "minutes"
            id_token      = "minutes"
            refresh_token = "days"
          }
          write_attributes = []
        }
      ]
    }
    qa = {
      create_cognito      = true
      create_jdbc_secrets = true

      jdbc_secrets = {
        alfaprd_dev = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfaprd-dev"
          description             = "Secret to store JDBC connection data to alfaprd dev"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        alfaprd_qa = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfaprd-qa"
          description             = "Secret to store JDBC connection data to alfaprd qa"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        alfaprd_cer = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfaprd-cer"
          description             = "Secret to store JDBC connection data to alfaprd cer"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        alfacomp_dev = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfacomp-dev"
          description             = "Secret to store JDBC connection data to alfacomp dev"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        alfacomp_qa = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfacomp-qa"
          description             = "Secret to store JDBC connection data to alfacomp qa"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
      }

      clients = [
        {
          name                                 = "${var.prefix}-${terraform.workspace}-niif-api"
          generate_secret                      = true
          access_token_validity                = "5"
          allowed_oauth_flows                  = ["implicit"]
          allowed_oauth_flows_user_pool_client = "true"
          allowed_oauth_scopes                 = ["openid", "email", "profile"]
          auth_session_validity                = "3"
          callback_urls                        = ["https://d5qmm9fi64.execute-api.us-east-1.amazonaws.com/qa/post_login"]
          enable_token_revocation              = "false"
          explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
          id_token_validity                    = "5"
          logout_urls                          = ["https://localhost:/logout"]
          prevent_user_existence_errors        = "ENABLED"
          read_attributes                      = ["profile", "email", "email_verified", "name", "given_name", "middle_name", "family_name", "preferred_username", "phone_number"]
          refresh_token_validity               = "1"
          supported_identity_providers         = ["COGNITO"]
          token_validity_units = {
            access_token  = "minutes"
            id_token      = "minutes"
            refresh_token = "days"
          }
          write_attributes = []
        }
      ]
    }
    prd = {
      create_cognito      = true
      create_jdbc_secrets = true

      jdbc_secrets = {
        alfaprd_prd = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfaprd-prd"
          description             = "Secret to store JDBC connection data to alfaprd prod"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        alfacomp_prd = {
          name                    = "/${var.prefix}/${terraform.workspace}/alfacomp-prd"
          description             = "Secret to store JDBC connection data to alfacomp prod"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
      }

      clients = [
        {
          name                                 = "${var.prefix}-${terraform.workspace}-niif-api"
          generate_secret                      = true
          access_token_validity                = "5"
          allowed_oauth_flows                  = ["implicit"]
          allowed_oauth_flows_user_pool_client = "true"
          allowed_oauth_scopes                 = ["openid", "email", "profile"]
          auth_session_validity                = "3"
          callback_urls                        = ["https://localhost/post_login"]
          enable_token_revocation              = "false"
          explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
          id_token_validity                    = "5"
          logout_urls                          = ["https://localhost:/logout"]
          prevent_user_existence_errors        = "ENABLED"
          read_attributes                      = ["profile", "email", "email_verified", "name", "given_name", "middle_name", "family_name", "preferred_username", "phone_number"]
          refresh_token_validity               = "1"
          supported_identity_providers         = ["COGNITO"]
          token_validity_units = {
            access_token  = "minutes"
            id_token      = "minutes"
            refresh_token = "days"
          }
          write_attributes = []
        }
      ]
    }
  }
  # Set workspace parameters for the associated environment
  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}

```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.62.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cognito"></a> [cognito](#module\_cognito) | ../../modules/terraform-aws-cognito-user-pool | n/a |
| <a name="module_jdbc_secret_manager"></a> [jdbc\_secret\_manager](#module\_jdbc\_secret\_manager) | terraform-aws-modules/secrets-manager/aws | 1.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.key_policy_infra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.key_policy_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | Variable for AWS Access Key | `string` | `null` | no |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | Variable for AWS Secret Key | `string` | `null` | no |
| <a name="input_aws_token"></a> [aws\_token](#input\_aws\_token) | Variable for AWS Token | `string` | `null` | no |
| <a name="input_infra_key_arn"></a> [infra\_key\_arn](#input\_infra\_key\_arn) | The ARN for the KMS encryption key | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for naming resources | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | Variable for credentials management. | `map(map(string))` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | A map of tags to add to all resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_jdbc_secret_ids"></a> [jdbc\_secret\_ids](#output\_jdbc\_secret\_ids) | Map with the IDs of the database credential secrets |

<!-- END_TF_DOCS -->