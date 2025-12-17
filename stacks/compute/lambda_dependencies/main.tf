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

module "ssm_ps_lambda_versions" {
  source = "terraform-aws-modules/ssm-parameter/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "1.1.0"

  for_each = local.workspace["lambda_versions"]

  create               = each.value.create
  name                 = each.value.name
  description          = each.value.description
  value                = "null"
  ignore_value_changes = true

  tags = local.workspace["tags"]
}

module "lambda_ecr" {
  source = "terraform-aws-modules/ecr/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "1.6.0"

  for_each = local.workspace["lambda_ecr"]

  create                             = each.value.create
  repository_name                    = each.value.repository_name
  create_lifecycle_policy            = local.workspace["create_lifecycle_policy"]
  repository_image_tag_mutability    = local.workspace["image_tag_mutability"]
  repository_encryption_type         = local.workspace["repository_encryption_type"]
  repository_kms_key                 = local.workspace["repository_kms_key"]
  repository_force_delete            = local.workspace["repository_force_delete"]
  repository_image_scan_on_push      = local.workspace["repository_image_scan_on_push"]
  repository_lifecycle_policy        = local.workspace["repository_lifecycle_policy"]
  repository_lambda_read_access_arns = local.workspace["repository_lambda_read_access_arns"]

  tags = local.workspace["tags"]
}
