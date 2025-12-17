locals {
  env = {
    default = {
      #############################################################################
      # Commons Parameters
      #############################################################################
      tags = {
        Environment = terraform.workspace
        Protected   = false
        Layer       = "Storage"
      }
      #############################################################################
      # cert_bucket Module
      #############################################################################
      create_cert_bucket              = false
      cert_bucket_name                = "eccomerce-${var.prefix}-${terraform.workspace}-pragma-certification"
      cert_bucket_force_destroy       = true
      cert_bucket_object_lock_enabled = false
      cert_bucket_lifecycle_rule      = []
      cert_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      cert_bucket_attach_policy = false
      cert_bucket_policy        = null

      cert_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }

      ###########################
      # EMAILS BUACKETS // datalake-pragma-ss
      ############################
      create_pragma_ss_bucket              = false
      pragma_ss_bucket_name                = "eccomerce-${var.prefix}-${terraform.workspace}-pragma-ss"
      pragma_ss_bucket_force_destroy       = true
      pragma_ss_bucket_object_lock_enabled = false
      pragma_ss_bucket_lifecycle_rule      = []
      pragma_ss_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      pragma_ss_bucket_attach_policy = false
      pragma_ss_bucket_policy        = null

      pragma_ss_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }

      //datalake-pragma-pcr
      create_pragma_pcr_bucket              = false
      pragma_pcr_bucket_name                = "eccomerce-${var.prefix}-${terraform.workspace}-pragma-pcr"
      pragma_pcr_bucket_force_destroy       = true
      pragma_pcr_bucket_object_lock_enabled = false
      pragma_pcr_bucket_lifecycle_rule      = []
      pragma_pcr_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      pragma_pcr_bucket_attach_policy = false
      pragma_pcr_bucket_policy        = null

      pragma_pcr_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }

       //datalake-pragma-con
      create_pragma_con_bucket              = false
      pragma_con_bucket_name                = "eccomerce-${var.prefix}-${terraform.workspace}-pragma-con"
      pragma_con_bucket_force_destroy       = true
      pragma_con_bucket_object_lock_enabled = false
      pragma_con_bucket_lifecycle_rule      = []
      pragma_con_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      pragma_con_bucket_attach_policy = false
      pragma_con_bucket_policy        = null

      pragma_con_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }

    //nuevo bucket parametros
      create_pragma_prm_bucket              = false
      pragma_prm_bucket_name                = "eccomerce-${var.prefix}-${terraform.workspace}-prm"
      pragma_prm_bucket_force_destroy       = true
      pragma_prm_bucket_object_lock_enabled = false
      pragma_prm_bucket_lifecycle_rule      = []
      pragma_prm_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      pragma_prm_bucket_attach_policy = false
      pragma_prm_bucket_policy        = null

      pragma_prm_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }
    //end nuevo bukect parametros

      //datalake-pragma-landing-prophet
      create_pragma_landing_prophet_bucket              = false
      pragma_landing_prophet_bucket_name                = "eccomerce-${var.prefix}-${terraform.workspace}-landing-prophet"
      pragma_landing_prophet_bucket_force_destroy       = true
      pragma_landing_prophet_bucket_object_lock_enabled = false
      pragma_landing_prophet_bucket_lifecycle_rule      = []
      pragma_landing_prophet_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      pragma_landing_prophet_bucket_attach_policy = false
      pragma_landing_prophet_bucket_policy        = null

      pragma_landing_prophet_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }




    }
    dev = {
      create_cert_bucket = true
      create_pragma_ss_bucket =  true
      create_pragma_pcr_bucket =  true
      create_pragma_con_bucket = true
      create_pragma_landing_prophet_bucket = true
    }
    qa = {
      create_cert_bucket = true
      create_pragma_ss_bucket =  true
      create_pragma_pcr_bucket =  true
      create_pragma_con_bucket = true
      create_pragma_prm_bucket = true  // parametros fun 1
    }
    prd = {
      create_cert_bucket = true
    }
  }
  # Set workspace parameters for the associated environment
  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
