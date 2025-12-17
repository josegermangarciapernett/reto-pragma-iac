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
      cert_bucket_name                = "alfa-${var.prefix}-${terraform.workspace}-niif-certification"
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
      # EMAILS BUACKETS // datalake-niif-ss
      ############################
      create_niif_ss_bucket              = false
      niif_ss_bucket_name                = "alfa-${var.prefix}-${terraform.workspace}-niif-ss"
      niif_ss_bucket_force_destroy       = true
      niif_ss_bucket_object_lock_enabled = false
      niif_ss_bucket_lifecycle_rule      = []
      niif_ss_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      niif_ss_bucket_attach_policy = false
      niif_ss_bucket_policy        = null

      niif_ss_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }

      //datalake-niif-pcr
      create_niif_pcr_bucket              = false
      niif_pcr_bucket_name                = "alfa-${var.prefix}-${terraform.workspace}-niif-pcr"
      niif_pcr_bucket_force_destroy       = true
      niif_pcr_bucket_object_lock_enabled = false
      niif_pcr_bucket_lifecycle_rule      = []
      niif_pcr_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      niif_pcr_bucket_attach_policy = false
      niif_pcr_bucket_policy        = null

      niif_pcr_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }

       //datalake-niif-con
      create_niif_con_bucket              = false
      niif_con_bucket_name                = "alfa-${var.prefix}-${terraform.workspace}-niif-con"
      niif_con_bucket_force_destroy       = true
      niif_con_bucket_object_lock_enabled = false
      niif_con_bucket_lifecycle_rule      = []
      niif_con_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      niif_con_bucket_attach_policy = false
      niif_con_bucket_policy        = null

      niif_con_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }

    //nuevo bucket parametros
      create_niif_prm_bucket              = false
      niif_prm_bucket_name                = "alfa-${var.prefix}-${terraform.workspace}-prm"
      niif_prm_bucket_force_destroy       = true
      niif_prm_bucket_object_lock_enabled = false
      niif_prm_bucket_lifecycle_rule      = []
      niif_prm_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      niif_prm_bucket_attach_policy = false
      niif_prm_bucket_policy        = null

      niif_prm_bucket_sse_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = var.storage_kms_key_arn
            sse_algorithm     = "aws:kms"
          }
        }
      }
    //end nuevo bukect parametros

      //datalake-niif-landing-prophet
      create_niif_landing_prophet_bucket              = false
      niif_landing_prophet_bucket_name                = "alfa-${var.prefix}-${terraform.workspace}-landing-prophet"
      niif_landing_prophet_bucket_force_destroy       = true
      niif_landing_prophet_bucket_object_lock_enabled = false
      niif_landing_prophet_bucket_lifecycle_rule      = []
      niif_landing_prophet_bucket_versioning = {
        status     = true
        mfa_delete = false
      }
      niif_landing_prophet_bucket_attach_policy = false
      niif_landing_prophet_bucket_policy        = null

      niif_landing_prophet_bucket_sse_configuration = {
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
      create_niif_ss_bucket =  true
      create_niif_pcr_bucket =  true
      create_niif_con_bucket = true
      create_niif_landing_prophet_bucket = true
    }
    qa = {
      create_cert_bucket = true
      create_niif_ss_bucket =  true
      create_niif_pcr_bucket =  true
      create_niif_con_bucket = true
      create_niif_prm_bucket = true  // parametros fun 1
    }
    prd = {
      create_cert_bucket = true
    }
  }
  # Set workspace parameters for the associated environment
  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
