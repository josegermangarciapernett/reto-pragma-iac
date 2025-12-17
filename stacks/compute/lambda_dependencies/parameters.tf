locals {
  env = {
    default = {
      #############################################################################
      # Common Parameters
      #############################################################################
      enabled_parameters = false
      tags = {
        Environment = terraform.workspace
        Layer       = "Compute"
      }
      #############################################################################
      # lambda_versions Module
      #############################################################################
      lambda_versions = {
        notification = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/niif/lambda/version/notification"
          description = "Parameters of the lambda Notification version"
        }
        post_login = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/niif/lambda/version/post-login"
          description = "Parameters of the lambda Post Login version"
        }
        certification = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/niif/lambda/version/certification"
          description = "Parameters of the lambda Certification version"
        }
      }
      #############################################################################
      # lambda_ecr Module
      #############################################################################
      lambda_ecr = {
        notification = {
          create          = true
          repository_name = "${var.prefix}_${terraform.workspace}_niif_notification"
        }
        post_login = {
          create          = true
          repository_name = "${var.prefix}_${terraform.workspace}_niif_post_login"
        }
        certification = {
          create          = true
          repository_name = "${var.prefix}_${terraform.workspace}_niif_certification"
        }
      }
      image_tag_mutability          = "MUTABLE"
      repository_encryption_type    = "KMS"
      repository_kms_key            = var.storage_key_arn
      repository_force_delete       = true
      repository_image_scan_on_push = true
      create_lifecycle_policy       = true
      repository_lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1,
            description  = "Delete untagged images",
            selection = {
              tagStatus   = "untagged",
              countType   = "sinceImagePushed",
              countUnit   = "days"
              countNumber = 1
            },
            action = {
              type = "expire"
            }
          },
          {
            rulePriority = 2,
            description  = "Keep last 10 images",
            selection = {
              tagStatus     = "tagged",
              tagPrefixList = ["v", "20"]
              countType     = "imageCountMoreThan",
              countNumber   = 10
            },
            action = {
              type = "expire"
            }
          }
        ]
      })
      repository_lambda_read_access_arns = [
        "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
      ]
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
