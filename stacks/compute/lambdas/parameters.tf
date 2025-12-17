locals {
  env = {
    default = {
      #############################################################################
      # Common Parameters
      #############################################################################
      tags = {
        Environment = terraform.workspace
        Layer       = "Compute"
      }
      #############################################################################
      #  lambdas Module
      #############################################################################
      create_smb_lambda      = false
      smb_lambda_name        = "${var.prefix}-${terraform.workspace}-smb-lambda"
      smb_lambda_description = "Lambda funtion to event async get"
      smb_lambda_handler     = ""
      smb_lambda_runtime     = ""
      smb_lambda_memory_size = 1024
      smb_lambda_timeout     = 330

      smb_lambda_environment_variables = {
        # BUCKET_NAME = var.assets_bucket_id
        BUCKET_PATH = "FS_files/"
        SECRET_NAME = "/${var.prefix}/${terraform.workspace}/filesystem"
      }

      smb_lambda_architectures = ["x86_64"]

      smb_lambda_create_package = false
      smb_lambda_package_type   = "Image"

      smb_lambda_ignore_source_code_hash = false
      smb_lambda_s3_existing_package     = null
      smb_lambda_local_existing_package  = null

      smb_lambda_image_uri = null

      smb_lambda_create_role                   = true
      smb_lambda_role_name                     = "${var.prefix}-${terraform.workspace}-smb-lambda-role"
      smb_lambda_policy_name                   = "${var.prefix}-${terraform.workspace}-smb-lambda-policy"
      smb_lambda_attach_cloudwatch_logs_policy = true
      smb_lambda_attach_tracing_policy         = true
      smb_lambda_attach_policies               = true
      smb_lambda_attach_policy_statements      = false
      smb_lambda_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
      ]
      smb_lambda_policy_statements = {}


      smb_lambda_allowed_triggers                        = {}
      smb_lambda_event_source_mapping                    = {}
      smb_lambda_create_current_version_allowed_triggers = false

      smb_lambda_attach_network_policy = true
      # smb_lambda_vpc_subnet_ids         = var.private_subnet_ids
      # smb_lambda_vpc_security_group_ids = [var.smb_lambda_sg_id]
      #############################################################################
      #  cont_lambda Module
      #############################################################################
      create_cont_lambda      = false
      cont_lambda_name        = "${var.prefix}-${terraform.workspace}-contingency-lambda"
      cont_lambda_description = "Lambda funtion select data source"
      cont_lambda_handler     = ""
      cont_lambda_runtime     = ""
      cont_lambda_memory_size = 1024
      cont_lambda_timeout     = 300

      cont_lambda_environment_variables = {
        LOG_LEVEL = "INFO"
      }

      cont_lambda_architectures = ["x86_64"]

      cont_lambda_create_package = false
      cont_lambda_package_type   = "Image"

      cont_lambda_ignore_source_code_hash = false
      cont_lambda_s3_existing_package     = null
      cont_lambda_local_existing_package  = null

      cont_lambda_image_uri = null

      cont_lambda_create_role                   = true
      cont_lambda_role_name                     = "${var.prefix}-${terraform.workspace}-cont-lambda-role"
      cont_lambda_policy_name                   = "${var.prefix}-${terraform.workspace}-cont-lambda-policy"
      cont_lambda_attach_cloudwatch_logs_policy = true
      cont_lambda_attach_tracing_policy         = true
      cont_lambda_attach_policies               = true
      cont_lambda_attach_policy_statements      = false
      cont_lambda_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
        "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
        "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
      ]
      cont_lambda_policy_statements = {}


      cont_lambda_allowed_triggers                        = {}
      cont_lambda_event_source_mapping                    = {}
      cont_lambda_create_current_version_allowed_triggers = false

      cont_lambda_attach_network_policy = true
      # cont_lambda_vpc_subnet_ids         = var.private_subnet_ids
      # cont_lambda_vpc_security_group_ids = [var.smb_lambda_sg_id]
    }
    dev = {

    }
    qa = {

    }
    prd = {

    }
  }
  # Set workspace parameters for the associated environment
  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
