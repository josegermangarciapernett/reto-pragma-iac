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
        eccomerceprd_dev = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomerceprd-dev"
          description             = "Secret to store JDBC connection data to eccomerceprd dev"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        eccomerceprd_qa = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomerceprd-qa"
          description             = "Secret to store JDBC connection data to eccomerceprd qa"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        eccomerceprd_cer = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomerceprd-cer"
          description             = "Secret to store JDBC connection data to eccomerceprd cer"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        ///new secret nuevos ambientes eccomerceprd-pre
        eccomerceprd_pre = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomerceprd-pre"
          description             = "Secret to store JDBC connection data to eccomerceprd pre"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        /// end secret nuevos ambientes eccomerceprd-pre
        eccomercecomp_dev = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomercecomp-dev"
          description             = "Secret to store JDBC connection data to eccomercecomp dev"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        eccomercecomp_qa = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomercecomp-qa"
          description             = "Secret to store JDBC connection data to eccomercecomp qa"
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
          supported_identity_providers         = ["COGNITO","AzureAD"]
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
        eccomerceprd_dev = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomerceprd-dev"
          description             = "Secret to store JDBC connection data to eccomerceprd dev"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        eccomerceprd_qa = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomerceprd-qa"
          description             = "Secret to store JDBC connection data to eccomerceprd qa"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        eccomerceprd_cer = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomerceprd-cer"
          description             = "Secret to store JDBC connection data to eccomerceprd cer"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        eccomercecomp_dev = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomercecomp-dev"
          description             = "Secret to store JDBC connection data to eccomercecomp dev"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        eccomercecomp_qa = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomercecomp-qa"
          description             = "Secret to store JDBC connection data to eccomercecomp qa"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        ///new secret nuevos ambientes eccomerceprd-pre
        eccomerceprd_pre = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomerceprd-pre"
          description             = "Secret to store JDBC connection data to eccomerceprd pre"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        /// end secret nuevos ambientes eccomerceprd-pre
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
          supported_identity_providers         = ["COGNITO","AzureAD"]
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
        eccomerceprd_prd = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomerceprd-prd"
          description             = "Secret to store JDBC connection data to eccomerceprd prod"
          recovery_window_in_days = 30
          ignore_secret_changes   = true
        }
        eccomercecomp_prd = {
          name                    = "/${var.prefix}/${terraform.workspace}/eccomercecomp-prd"
          description             = "Secret to store JDBC connection data to eccomercecomp prod"
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
          supported_identity_providers         = ["COGNITO","AzureAD"]
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
