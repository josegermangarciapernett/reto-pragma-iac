/*
* # Module for Application resources deployment
* 
* Terraform stack to provision a custom ECS Service and Task Cluster using the following Terraform modules and resources:
* 
* ## Modules & Resources
* ### Module - storage_bucket
* **Source Module info:**
* - **Version** : "3.15.0"
* - **Link**    : [terraform-aws-modules/s3-bucket/aws](github.com/terraform-aws-modules/terraform-aws-s3-bucket)
* 
*/

module "cert_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "3.15.0"

  create_bucket       = local.workspace["create_cert_bucket"]
  bucket              = local.workspace["cert_bucket_name"]
  force_destroy       = local.workspace["cert_bucket_force_destroy"]
  object_lock_enabled = local.workspace["cert_bucket_object_lock_enabled"]
  lifecycle_rule      = local.workspace["cert_bucket_lifecycle_rule"]
  versioning          = local.workspace["cert_bucket_versioning"]
  attach_policy       = local.workspace["cert_bucket_attach_policy"]
  policy              = local.workspace["cert_bucket_policy"]

  server_side_encryption_configuration = local.workspace["cert_bucket_sse_configuration"]

  tags = local.workspace["tags"]
}

module "create_niif_ss" {
  source = "terraform-aws-modules/s3-bucket/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "3.15.0"

  create_bucket       = local.workspace["create_niif_ss_bucket"]
  bucket              = local.workspace["niif_ss_bucket_name"]
  force_destroy       = local.workspace["niif_ss_bucket_force_destroy"]
  object_lock_enabled = local.workspace["niif_ss_bucket_object_lock_enabled"]
  lifecycle_rule      = local.workspace["niif_ss_bucket_lifecycle_rule"]
  versioning          = local.workspace["niif_ss_bucket_versioning"]
  attach_policy       = local.workspace["niif_ss_bucket_attach_policy"]
  policy              = local.workspace["niif_ss_bucket_policy"]

  server_side_encryption_configuration = local.workspace["niif_ss_bucket_sse_configuration"]

  tags = local.workspace["tags"]
}

module "create_niif_pcr" {
  source = "terraform-aws-modules/s3-bucket/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "3.15.0"

  create_bucket       = local.workspace["create_niif_pcr_bucket"]
  bucket              = local.workspace["niif_pcr_bucket_name"]
  force_destroy       = local.workspace["niif_pcr_bucket_force_destroy"]
  object_lock_enabled = local.workspace["niif_pcr_bucket_object_lock_enabled"]
  lifecycle_rule      = local.workspace["niif_pcr_bucket_lifecycle_rule"]
  versioning          = local.workspace["niif_pcr_bucket_versioning"]
  attach_policy       = local.workspace["niif_pcr_bucket_attach_policy"]
  policy              = local.workspace["niif_pcr_bucket_policy"]

  server_side_encryption_configuration = local.workspace["niif_pcr_bucket_sse_configuration"]

  tags = local.workspace["tags"]
}

module "create_niif_con" {
  source = "terraform-aws-modules/s3-bucket/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "3.15.0"

  create_bucket       = local.workspace["create_niif_con_bucket"]
  bucket              = local.workspace["niif_con_bucket_name"]
  force_destroy       = local.workspace["niif_con_bucket_force_destroy"]
  object_lock_enabled = local.workspace["niif_con_bucket_object_lock_enabled"]
  lifecycle_rule      = local.workspace["niif_con_bucket_lifecycle_rule"]
  versioning          = local.workspace["niif_con_bucket_versioning"]
  attach_policy       = local.workspace["niif_con_bucket_attach_policy"]
  policy              = local.workspace["niif_con_bucket_policy"]

  server_side_encryption_configuration = local.workspace["niif_con_bucket_sse_configuration"]

  tags = local.workspace["tags"]
}

module "create_niif_landing_prophet" {
  source = "terraform-aws-modules/s3-bucket/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "3.15.0"

  create_bucket       = local.workspace["create_niif_landing_prophet_bucket"]
  bucket              = local.workspace["niif_landing_prophet_bucket_name"]
  force_destroy       = local.workspace["niif_landing_prophet_bucket_force_destroy"]
  object_lock_enabled = local.workspace["niif_landing_prophet_bucket_object_lock_enabled"]
  lifecycle_rule      = local.workspace["niif_landing_prophet_bucket_lifecycle_rule"]
  versioning          = local.workspace["niif_landing_prophet_bucket_versioning"]
  attach_policy       = local.workspace["niif_landing_prophet_bucket_attach_policy"]
  policy              = local.workspace["niif_landing_prophet_bucket_policy"]

  server_side_encryption_configuration = local.workspace["niif_landing_prophet_bucket_sse_configuration"]

  tags = local.workspace["tags"]
}

module "create_niif_prm" {
  source = "terraform-aws-modules/s3-bucket/aws"
  #checkov:skip=CKV_TF_1:The commit hash is not require here
  version = "3.15.0"

  create_bucket       = local.workspace["create_niif_prm_bucket"]
  bucket              = local.workspace["niif_prm_bucket_name"]
  force_destroy       = local.workspace["niif_prm_bucket_force_destroy"]
  object_lock_enabled = local.workspace["niif_prm_bucket_object_lock_enabled"]
  lifecycle_rule      = local.workspace["niif_prm_bucket_lifecycle_rule"]
  versioning          = local.workspace["niif_prm_bucket_versioning"]
  attach_policy       = local.workspace["niif_prm_bucket_attach_policy"]
  policy              = local.workspace["niif_prm_bucket_policy"]

  server_side_encryption_configuration = local.workspace["niif_prm_bucket_sse_configuration"]

  tags = local.workspace["tags"]
}
