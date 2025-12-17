/*
* # Module for Compute deployment
* 
* Terraform stack to provision compute elements using the next Terraform modules and resources:
* 
* ## Modules & Resources
* ### Module - lambda
* **Source Module info:**
* - **Version** : "6.0.1"
* - **Link**    : [terraform-aws-modules/lambda/aws](github.com/terraform-aws-modules/terraform-aws-lambda)
* 
*/

# module "smb_lambda_version" {
#   source = "terraform-aws-modules/ssm-parameter/aws"
#   #checkov:skip=CKV_TF_1:The commit hash is not require here
#   version = "1.1.0"

#   create               = true
#   name                 = "/${var.prefix}/${terraform.workspace}/lambda/sbm/version"
#   description          = "Parameters of the lambda SMB version"
#   value                = "null"
#   ignore_value_changes = true

#   tags = {
#     Environment = terraform.workspace
#     Protected   = false
#     Layer       = "Compute"
#   }
# }

# module "contingency_lambda_version" {
#   source = "terraform-aws-modules/ssm-parameter/aws"
#   #checkov:skip=CKV_TF_1:The commit hash is not require here
#   version = "1.1.0"

#   create               = true
#   name                 = "/${var.prefix}/${terraform.workspace}/lambda/contingency/version"
#   description          = "Parameters of the lambda contingency version"
#   value                = "null"
#   ignore_value_changes = true

#   tags = {
#     Environment = terraform.workspace
#     Protected   = false
#     Layer       = "Compute"
#   }
# }

# module "smb_ecr" {
#   source = "terraform-aws-modules/ecr/aws"
#   #checkov:skip=CKV_TF_1:The commit hash is not require here
#   version = "1.6.0"

#   create                             = local.workspace["create_smb_ecr"]
#   create_lifecycle_policy            = local.workspace["create_lifecycle_policy"]
#   repository_name                    = local.workspace["smb_ecr_repository_name"]
#   repository_image_tag_mutability    = local.workspace["image_tag_mutability"]
#   repository_encryption_type         = local.workspace["repository_encryption_type"]
#   repository_kms_key                 = local.workspace["repository_kms_key"]
#   repository_force_delete            = local.workspace["repository_force_delete"]
#   repository_image_scan_on_push      = local.workspace["repository_image_scan_on_push"]
#   repository_lifecycle_policy        = local.workspace["repository_lifecycle_policy"]
#   repository_lambda_read_access_arns = local.workspace["repository_lambda_read_access_arns"]

#   tags = local.workspace["tags"]
# }

# module "contingency_ecr" {
#   source = "terraform-aws-modules/ecr/aws"
#   #checkov:skip=CKV_TF_1:The commit hash is not require here
#   version = "1.6.0"

#   create                             = local.workspace["create_cont_ecr"]
#   create_lifecycle_policy            = local.workspace["create_lifecycle_policy"]
#   repository_name                    = local.workspace["cont_ecr_repository_name"]
#   repository_image_tag_mutability    = local.workspace["image_tag_mutability"]
#   repository_encryption_type         = local.workspace["repository_encryption_type"]
#   repository_kms_key                 = local.workspace["repository_kms_key"]
#   repository_force_delete            = local.workspace["repository_force_delete"]
#   repository_image_scan_on_push      = local.workspace["repository_image_scan_on_push"]
#   repository_lifecycle_policy        = local.workspace["repository_lifecycle_policy"]
#   repository_lambda_read_access_arns = local.workspace["repository_lambda_read_access_arns"]

#   tags = local.workspace["tags"]
# }

# locals {
#   create_smb_lambda = var.create_smb_lambda && local.workspace["create_smb_lambda"] ? data.aws_ssm_parameter.smb_lambda_version.insecure_value != "null" : false

#   create_cont_lambda = var.create_cont_lambda && local.workspace["create_cont_lambda"] ? data.aws_ssm_parameter.contingency_lambda_version.insecure_value != "null" : false
# }

# module "smb_lambda" {
#   source = "terraform-aws-modules/lambda/aws"
#   #checkov:skip=CKV_TF_1:The commit hash is not require here
#   version = "7.9.0"

#   create        = local.create_smb_lambda
#   function_name = local.workspace["smb_lambda_name"]
#   description   = local.workspace["smb_lambda_description"]
#   handler       = local.workspace["smb_lambda_handler"]
#   runtime       = local.workspace["smb_lambda_runtime"]
#   memory_size   = local.workspace["smb_lambda_memory_size"]
#   timeout       = local.workspace["smb_lambda_timeout"]

#   environment_variables = local.workspace["smb_lambda_environment_variables"]

#   architectures = local.workspace["smb_lambda_architectures"]

#   create_package = local.workspace["smb_lambda_create_package"]
#   package_type   = local.workspace["smb_lambda_package_type"]

#   ignore_source_code_hash = local.workspace["smb_lambda_ignore_source_code_hash"]
#   s3_existing_package     = local.workspace["smb_lambda_s3_existing_package"]
#   local_existing_package  = local.workspace["smb_lambda_local_existing_package"]

#   image_uri = format("%s:%s",
#     module.smb_ecr.repository_url,
#     data.aws_ssm_parameter.smb_lambda_version.insecure_value
#   )

#   create_role                   = local.workspace["smb_lambda_create_role"]
#   role_name                     = local.workspace["smb_lambda_role_name"]
#   policy_name                   = local.workspace["smb_lambda_policy_name"]
#   attach_cloudwatch_logs_policy = local.workspace["smb_lambda_attach_cloudwatch_logs_policy"]
#   attach_tracing_policy         = local.workspace["smb_lambda_attach_tracing_policy"]
#   attach_policies               = local.workspace["smb_lambda_attach_policies"]
#   attach_policy_statements      = local.workspace["smb_lambda_attach_policy_statements"]
#   number_of_policies            = length(local.workspace["smb_lambda_policies"])
#   policies                      = local.workspace["smb_lambda_policies"]
#   policy_statements             = local.workspace["smb_lambda_policy_statements"]

#   allowed_triggers                        = local.workspace["smb_lambda_allowed_triggers"]
#   event_source_mapping                    = local.workspace["smb_lambda_event_source_mapping"]
#   create_current_version_allowed_triggers = local.workspace["smb_lambda_create_current_version_allowed_triggers"]

#   attach_network_policy  = local.workspace["smb_lambda_attach_network_policy"]
#   vpc_subnet_ids         = local.workspace["smb_lambda_vpc_subnet_ids"]
#   vpc_security_group_ids = local.workspace["smb_lambda_vpc_security_group_ids"]

#   tags = local.workspace["tags"]

#   depends_on = [module.smb_lambda_version]
# }

# module "contingency_lambda" {
#   source = "terraform-aws-modules/lambda/aws"
#   #checkov:skip=CKV_TF_1:The commit hash is not require here
#   version = "7.9.0"

#   create        = local.create_cont_lambda
#   function_name = local.workspace["cont_lambda_name"]
#   description   = local.workspace["cont_lambda_description"]
#   handler       = local.workspace["cont_lambda_handler"]
#   runtime       = local.workspace["cont_lambda_runtime"]
#   memory_size   = local.workspace["cont_lambda_memory_size"]
#   timeout       = local.workspace["cont_lambda_timeout"]

#   environment_variables = local.workspace["cont_lambda_environment_variables"]

#   architectures = local.workspace["cont_lambda_architectures"]

#   create_package = local.workspace["cont_lambda_create_package"]
#   package_type   = local.workspace["cont_lambda_package_type"]

#   ignore_source_code_hash = local.workspace["cont_lambda_ignore_source_code_hash"]
#   s3_existing_package     = local.workspace["cont_lambda_s3_existing_package"]
#   local_existing_package  = local.workspace["cont_lambda_local_existing_package"]

#   image_uri = format("%s:%s",
#     module.contingency_ecr.repository_url,
#     data.aws_ssm_parameter.contingency_lambda_version.insecure_value
#   )

#   create_role                   = local.workspace["cont_lambda_create_role"]
#   role_name                     = local.workspace["cont_lambda_role_name"]
#   policy_name                   = local.workspace["cont_lambda_policy_name"]
#   attach_cloudwatch_logs_policy = local.workspace["cont_lambda_attach_cloudwatch_logs_policy"]
#   attach_tracing_policy         = local.workspace["cont_lambda_attach_tracing_policy"]
#   attach_policies               = local.workspace["cont_lambda_attach_policies"]
#   attach_policy_statements      = local.workspace["cont_lambda_attach_policy_statements"]
#   number_of_policies            = length(local.workspace["cont_lambda_policies"])
#   policies                      = local.workspace["cont_lambda_policies"]
#   policy_statements             = local.workspace["cont_lambda_policy_statements"]

#   allowed_triggers                        = local.workspace["cont_lambda_allowed_triggers"]
#   event_source_mapping                    = local.workspace["cont_lambda_event_source_mapping"]
#   create_current_version_allowed_triggers = local.workspace["cont_lambda_create_current_version_allowed_triggers"]

#   attach_network_policy  = local.workspace["cont_lambda_attach_network_policy"]
#   vpc_subnet_ids         = local.workspace["cont_lambda_vpc_subnet_ids"]
#   vpc_security_group_ids = local.workspace["cont_lambda_vpc_security_group_ids"]

#   tags = local.workspace["tags"]

#   depends_on = [module.smb_lambda_version]
# }
