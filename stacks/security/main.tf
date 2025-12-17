/*
* # Resources to Deploy Security Layer
* 
* Terraform code to provision custom resources associated with the security layer using the following Terraform modules and resources:
* 
* ## Modules & Resources
* ### Module - infra_kms
* **Description:** KMS key to encrypt infrastructure resources
* **Source Module info:**
* - **Version** : "1.5.0"
* - **Link**    : [terraform-aws-modules/kms/aws](github.com/terraform-aws-modules/terraform-aws-kms)
* ### Module - storage_kms
* **Description:** KMS key to encrypt storage resources
* **Source Module info:**
* - **Version** : "1.5.0"
* - **Link**    : [terraform-aws-modules/kms/aws](github.com/terraform-aws-modules/terraform-aws-kms)
* ### Module - cognito
* **Description:** KMS key to encrypt storage resources
* **Source Module info:**
* - **Version** : "1.0.0"
* - **Link**    : [terraform-aws-cognito-user-pool](../../modules/terraform-aws-cognito-user-pool)
* - **Origin**  : [lgallard/cognito-user-pool/aws](github.com/lgallard/terraform-aws-cognito-user-pool/blob/master/identity-provider.tf)
* ### Module acm
* **Description:**
* **Source Module info:**
* - **Version** : "4.3.2"
* - **Link**    :  [terraform-aws-modules/acm/aws](github.com/terraform-aws-modules/terraform-aws-acm)
* 
*/

module "jdbc_secret_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "1.1.2"

  for_each = local.workspace["jdbc_secrets"]

  create                  = local.workspace["create_jdbc_secrets"]
  name                    = each.value.name
  description             = each.value.description
  kms_key_id              = var.infra_key_arn
  recovery_window_in_days = each.value.recovery_window_in_days
  ignore_secret_changes   = each.value.ignore_secret_changes
  secret_string = jsonencode(
    {
      host     = ""
      port     = ""
      dbname   = ""
      engine   = ""
      username = ""
      password = ""
    }
  )

  tags = local.workspace["tags"]
}

module "cognito" {
  source = "../../modules/terraform-aws-cognito-user-pool"

  enabled                = local.workspace["create_cognito"]
  user_pool_name         = local.workspace["user_pool_name"]
  domain                 = local.workspace["domain"]
  domain_certificate_arn = local.workspace["domain_certificate_arn"]
  alias_attributes       = local.workspace["alias_attributes"]
  mfa_configuration      = local.workspace["mfa_configuration"]
  deletion_protection    = local.workspace["deletion_protection"]
  string_schemas         = local.workspace["string_schemas"]

  resource_server_name       = local.workspace["resource_server_name"]
  resource_server_identifier = local.workspace["resource_server_identifier"]
  resource_servers           = local.workspace["resource_servers"]
  identity_providers         = local.workspace["identity_providers"]
  clients                    = local.workspace["clients"]

  auto_verified_attributes   = local.workspace["auto_verified_attributes"]
  username_attributes        = local.workspace["username_attributes"]
  username_configuration     = local.workspace["username_configuration"]
  sms_authentication_message = local.workspace["sms_authentication_message"]
  admin_create_user_config   = local.workspace["admin_create_user_config"]
  email_configuration        = local.workspace["email_configuration"]
  password_policy            = local.workspace["password_policy"]
  recovery_mechanisms        = local.workspace["recovery_mechanisms"]

  verification_message_template = local.workspace["verification_message_template"]

  tags = local.workspace["tags"]
}
