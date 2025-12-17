locals {
  env = {
    default = {
      #############################################################################
      # Commons Parameters
      #############################################################################
      export_parameters = false
      tags = {
        Environment = terraform.workspace
        Protected   = "Shared"
        Layer       = "Analytics"
      }
      #####################################################################
      # iam_roles
      #####################################################################
      inline_policies = {
        general = [
          {
            sid = "AllowEC2Actions"
            actions = [
              "ec2:*"
            ]
            effect    = "Allow"
            resources = ["*"]
          },
          {
            sid = "AllowLogsActions"
            actions = [
              "logs:*"
            ]
            effect    = "Allow"
            resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/*"]
          },
          {
            sid = "AllowS3Actions"
            actions = [
              "s3:ListBucket",
              "s3:GetBucketLocation"
            ]
            effect = "Allow"
            resources = [
              "arn:aws:s3:::aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}",
              "arn:aws:s3:::${var.assets_bucket_id}",
              "arn:aws:s3:::${var.bronce_bucket_id}",
              "arn:aws:s3:::${var.silver_bucket_id}",
              "arn:aws:s3:::${var.gold_bucket_id}",
            ]
          },
          {
            sid = "AllowBucketActions"
            actions = [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject",
            ]
            effect = "Allow"
            resources = [
              "arn:aws:s3:::aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/*",
              "arn:aws:s3:::${var.assets_bucket_id}/*",
              "arn:aws:s3:::${var.bronce_bucket_id}/*",
              "arn:aws:s3:::${var.silver_bucket_id}/*",
              "arn:aws:s3:::${var.gold_bucket_id}/*",
            ]
          },
          {
            sid       = "AllowSecretsManagerActions"
            actions   = ["secretsmanager:GetSecretValue"]
            effect    = "Allow"
            resources = values(var.jdbc_secret_ids)
          },
          {
            sid = "AllowGlueActions"
            actions = [
              "glue:GetTable",
              "glue:GetTables",
              "glue:GetTableVersion",
              "glue:GetTableVersions",
              "glue:GetPartition",
              "glue:GetPartitions",
              "glue:GetDatabase",
              "glue:GetConnection",
              "glue:CreateTable",
              "glue:UpdateTable",
              "glue:UpdatePartition",
              "glue:BatchGetPartition",
              "glue:BatchCreatePartition",
              "glue:PublishDataQuality"
            ]
            effect = "Allow"
            resources = [
              "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
              "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/default",
              "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/default/*",
              "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/${var.prefix}-${terraform.workspace}*",
              "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.prefix}-${terraform.workspace}*",
              "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:connection/${var.prefix}-${terraform.workspace}*",
              "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dataQualityRuleset/*",
            ]
          },
          {
            sid = "AllowLakeformationActions"
            actions = [
              "lakeformation:*"
            ]
            effect    = "Allow"
            resources = ["*"]
          },
          {
            sid = "AllowSSMActions"
            actions = [
              "ssm:GetParameter"
            ]
            effect    = "Allow"
            resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/datalake/${terraform.workspace}/niif*"]
          }
        ]
      }

      job_roles = {
        bronce_layer = {
          create_role       = true
          role_name         = "${var.prefix}-${terraform.workspace}-niif-jobs-bronce-layer"
          role_requires_mfa = false
          trusted_role_services = [
            "glue.amazonaws.com"
          ]
          inline_policy           = "general"
          custom_role_policy_arns = []
        }
        silver_layer = {
          create_role       = true
          role_name         = "${var.prefix}-${terraform.workspace}-niif-jobs-silver-layer"
          role_requires_mfa = false
          trusted_role_services = [
            "glue.amazonaws.com"
          ]
          inline_policy           = "general"
          custom_role_policy_arns = []
        }
        gold_layer = {
          create_role       = true
          role_name         = "${var.prefix}-${terraform.workspace}-niif-jobs-gold-layer"
          role_requires_mfa = false
          trusted_role_services = [
            "glue.amazonaws.com"
          ]
          inline_policy           = "general"
          custom_role_policy_arns = []
        }
      }

      ######################################################################
      # glue_jobs Module
      ######################################################################
      job_alfprd_general_bronce_extract = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-alfprd-general-bronce-extract"
        job_description = "Job to extract data from alfprd general"
        role            = "bronce_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.bronce_bucket_id
          "--CERTIFICATE"        = "False"
          "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-alfaprd-cer-connection"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "GENERAL"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/bronce_extract.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_alfprd_prv_bronce_extract = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-alfprd-prv-bronce-extract"
        job_description = "Job to extract data from alfprd prv"
        role            = "bronce_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.bronce_bucket_id
          "--CERTIFICATE"        = "False"
          "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-alfaprd-qa-connection"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "PRV"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/bronce_extract.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_alfprd_arpprod_bronce_extract = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-alfprd-arpprod-bronce-extract"
        job_description = "Job to extract data from alfprd arpprod"
        role            = "bronce_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.bronce_bucket_id
          "--CERTIFICATE"        = "False"
          "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-alfaprd-qa-connection"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "ARPPROD"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/bronce_extract.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_alfprd_general_bronce_quality = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-alfprd-general-bronce-quality"
        job_description = "Job to manipulate data from alfprd general"
        role            = "bronce_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.bronce_bucket_id
          "--CERTIFICATE"        = "False"
          "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-alfaprd-qa-connection"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "GENERAL"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/bronce_quality.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_alfprd_prv_bronce_quality = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-alfprd-prv-bronce-quality"
        job_description = "Job to manipulate data from alfprd prv"
        role            = "bronce_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.bronce_bucket_id
          "--CERTIFICATE"        = "False"
          "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-alfaprd-qa-connection"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "PRV"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/bronce_quality.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_alfprd_arpprod_bronce_quality = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-alfprd-arpprod-bronce-quality"
        job_description = "Job to manipulate data from alfprd arpprod"
        role            = "bronce_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.bronce_bucket_id
          "--CERTIFICATE"        = "False"
          "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-alfaprd-qa-connection"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "ARPPROD"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/bronce_quality.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

/////init nuevos jobs PCR BRONCE/// 
      job_files_bronce_extract = {
              create          = true
              job_name        = "${var.prefix}-${terraform.workspace}-files-bronce-extract"
              job_description = "Job to files bronce extrac"
              role            = "bronce_layer"
              glue_version    = "4.0"
              default_arguments = {
                "--enable-metrics"                   = "true"
                "--enable-continuous-cloudwatch-log" = "true"
                "--enable-job-insights"              = "true"
                "--enable-spark-ui"                  = "true"
                "--enable-glue-datacatalog"          = "true"
                "--job-language"                     = "python"
                "--job-bookmark-option"              = "job-bookmark-disable"
                "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
                "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
                "--extra-py-files" = format("%s,%s,%s,%s",
                  "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
                  "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
                  "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
                "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
                "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
                "--BUCKET_NAME"        = var.bronce_bucket_id
                "--CERTIFICATE"        = "False"
                "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-acsele-sop-connection"
                "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
                "--DB_NAME"            = "ACSELE"
                "--DB_SCHEMA"          = "ACSELE_ALFA"
                "--PATH_JSON"          = "support_phase_files/niif/files_niif.json"
                "--PERIOD"             = "202501"
              }

              worker_type       = "G.1X"
              number_of_workers = 10
              max_retries       = 0
              timeout           = 2880

              command = {
                name            = "glueetl"
                python_version  = 3
                script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/files_bronce_dev_extract.py"
              }

              execution_property = {
                max_concurrent_runs = "1"
              }
            }




      job_acsele_alfa_bronce_granular_extract = {
              create          = true
              job_name        = "${var.prefix}-${terraform.workspace}-acsele-alfa-bronce-granular-extract"
              job_description = "Job to acsele alfa bronce granular extract"
              role            = "bronce_layer"
              glue_version    = "4.0"
              default_arguments = {
                "--enable-metrics"                   = "true"
                "--enable-continuous-cloudwatch-log" = "true"
                "--enable-job-insights"              = "true"
                "--enable-spark-ui"                  = "true"
                "--enable-glue-datacatalog"          = "true"
                "--job-language"                     = "python"
                "--job-bookmark-option"              = "job-bookmark-disable"
                "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
                "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
                "--extra-py-files" = format("%s,%s,%s,%s",
                  "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
                  "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
                  "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
                "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
                "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
                "--BUCKET_NAME"        = var.bronce_bucket_id
                "--CERTIFICATE"        = "False"
                "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-acsele-sop-connection"
                "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
                "--DB_NAME"            = "IPA-ACSELE-QA"
                "--DB_SCHEMA"          = "ACSELE_ALFA"
                "--PATH_JSON"          = "support_phase_files/niif/acsele_alfa_tables.json"
                "--PERIOD"             = "202501"
              }

              worker_type       = "G.1X"
              number_of_workers = 10
              max_retries       = 0
              timeout           = 2880

              command = {
                name            = "glueetl"
                python_version  = 3
                script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/acsele_alfa_bronce_dev_granular_extract.py"
              }

              execution_property = {
                max_concurrent_runs = "1"
              }
            }



      job_acsele_alfa_bronce_quality = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-acsele-alfa-bronce-quality"
        job_description = "Job to acsele alfa bronce Quality"
        role            = "bronce_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.bronce_bucket_id
          "--CERTIFICATE"        = "False"
          "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-acsele-sop-connection"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ACSELE"
          "--DB_SCHEMA"          = "ACSELE_ALFA"
          "--PATH_JSON"          = "support_phase_files/niif/acsele_alfa_tables.json"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/acsele_alfa_bronce_dev_quality.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }
///end nuevo jobs

/////NEW BRONCE JOBS 22/07/2025
//files_bronce_qa_extract_quality
        job_files_bronce_extract_quality = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-files-bronce-quality"
        job_description = "Job to Files Extract alfa bronce Quality"
        role            = "bronce_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--CERTIFICATE"        = "False" // ok
       // "--CASE_USE_EVALUATE"  = jsonencode(["NIIF17_CAMPOS_UNICA_VEZ"])   //CAMPO NUEVO
          "--CASE_USE_EVALUATE"  = jsonencode(["NIIF17_IPCTASATECNICA"])   //CAMPO NUEVO
          "--PERIOD"             =  "202501"  //ok
          "--TABLES_PARAMS"      = jsonencode({ "artefacto": "datalake-qa-artefacto", "acn": "datalake-qa-artefacto-concepto-nota-params", "concepto": "datalake-qa-concepto", "nota": "datalake-qa-nota" })
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/files_bronce_dev_quality_extract.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }
///END BRONCE JOBS

/////5-09-2025  init nuevos jobs PCR SILVER///pcrtradicional_silver_dev_transformation
job_pcrtradicional_silver_transformation = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-pcrtradicional-silver-transformation"
        job_description = "Job to pcrtradicional transformation data"
        role            = "silver_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.silver_bucket_id
          "--BUCKET_NAME_BRONCE" = "alfa-datalake-qa-bronce"
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--CONNECT_NAME"       = "${var.prefix}-${terraform.workspace}-acsele-sop-connection"
          "--DB_NAME"            = "ACSELE"
          "--DB_SCHEMA"          = "ACSELE_ALFA_FULL"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
           script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/pcrtradicional_silver_dev_transformation.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }
///end nuevo jobs  --- PRC SILVER  ACTUALIZADO LISTO

//jobs new primas arl transformation
job_primasarl_silver_transformation = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-primasarl-silver-transformation"
        job_description = "Job to pcrtradicional transformation data"
        role            = "silver_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.silver_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "['GENERAL','ARPPROD']"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
           script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/primasarl_silver_dev_transformation.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }
///end nuevo Jobs
      job_auxiliofunerario_silver_transformation = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-auxiliofunerario-silver-transformation"
        job_description = "Job to transform auxiliofunerario data"
        role            = "silver_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.silver_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "GENERAL"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/auxiliofunerario_silver_dev_transformation.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_primasrentas_silver_transformation = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-primasrentas-silver-transformation"
        job_description = "Job to transform primasrentas data"
        role            = "silver_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.silver_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "['GENERAL','PRV']"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/primasrentas_silver_dev_transformation.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_reserva_arpprod_silver_transformation = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-reserva-arpprod-silver-transformation"
        job_description = "Job to transform reserva arpprod data"
        role            = "silver_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME"        = var.silver_bucket_id
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "ARPPROD"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/reservamatematica_arpprod_silver_dev_transformation.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_reserva_general_silver_transformation = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-reserva-general-silver-transformation"
        job_description = "Job to transform reserva general data"
        role            = "silver_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME"        = var.silver_bucket_id
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "GENERAL"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/reservamatematica_general_silver_dev_transformation.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_reserva_prv_silver_transformation = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-reserva-prv-silver-transformation"
        job_description = "Job to transform reserva prv data"
        role            = "silver_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME"        = var.silver_bucket_id
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "PRV"
          "--PERIOD"             = "202501"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/reservamatematica_prv_silver_dev_transformation.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }



      job_auxiliofunerario_gold_reports = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-auxiliofunerario-gold-reports"
        job_description = "Job to report auxiliofunerario data"
        role            = "gold_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.gold_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "GENERAL"
          "--PERIOD"             = "202501"
          "--TABLE_NAME_GOLD"    = "AUXILIOS_FUNERARIOS_GOLD"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/auxiliofunerario_gold_dev_reports.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_primasrentas_gold_reports = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-primasrentas-gold-reports"
        job_description = "Job to report primasrentas data"
        role            = "gold_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.gold_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "GENERAL"
          "--PERIOD"             = "202501"
          "--TABLE_NAME_GOLD"    = "PRIMAS_RENTAS_GOLD"
          "--CONSTANTS"          = "Renta nueva"
          "--TABLE_NAME_GOLD"    = "PRIMAS_RENTAS_RENTAS_GOLD"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/primasrentas_gold_dev_reports.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_reserva_arp_gold_reports = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-reserva-arp-gold-reports"
        job_description = "Job to report reserva arp data"
        role            = "gold_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS"        = var.assets_bucket_id
          "--BUCKET_NAME"               = var.gold_bucket_id
          "--CERTIFICATE"               = "False"
          "--DB_CATALOG_GLUE_SILVER"    = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
          "--DB_NAME"                   = "ALFAPRD"
          "--DB_SCHEMA"                 = "ARPPROD AND GENERAL"
          "--FEC_CORTE_DATE"            = "2025-04-16"
          "--PARAMS_NAME"               = "['deslizamiento','gastos']"
          "--PARAMS_PATH"               = "/datalake/${terraform.workspace}/niif17/"
          "--PERIOD"                    = "202412"
          "--TABLE_NAME_GOLD"           = "RESERVA_ARP_GOLD"
          "--DB_CATALOG_GLUE_BRONCE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/reservamatematica_arp_gold_dev_reports.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      job_reserva_rvi_gold_reports = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-reserva-rvi-gold-reports"
        job_description = "Job to report reserva rvi data"
        role            = "gold_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.gold_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE_SILVER"    = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
          "--DB_CATALOG_GLUE_BRONCE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "PRV AND GENERAL"
          "--FEC_CORTE_DATE"     = "2024-12-01"
          "--PARAMS_NAME"        = "['tasa_fac_seg']"
          "--PARAMS_PATH"        = "/datalake/${terraform.workspace}/niif17/"
          "--PERIOD"             = "202412"
          "--TABLE_NAME_GOLD"    = "RESERVA_RVI_GOLD"
          "--VALORES_CONSTANTES" = jsonencode({"POR_AMORT_ACUM": "0", "VALOR_RESERVA_RV08": "0", "VALOR_RESERVA_RV89": "0" })

          
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/reservamatematica_rvi_gold_dev_reports.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }

      ///jobs new gold 
        job_primasarl_gold_reports = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-primasarl-gold-reports"
        job_description = "Job to report reserva rvi data"
        role            = "gold_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.gold_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "GENERAL"
          "--PERIOD"             = "202501"
          "--TABLE_NAME_GOLD"    = "PRIMAS_ARL_GOLD"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/primasarl_gold_dev_reports.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }
      //en jobs new gold



//////NUEVO JOBS /// PRIMAS ENDOSOS LAYER GOLD
        job_primasrentasendosos_gold_reports = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-primasrentasendosos-gold-reports"
        job_description = "Job to report primasrentasendosos data report"
        role            = "gold_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.gold_bucket_id
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "GENERAL"
          "--PERIOD"             = "202501"
          "--TABLE_NAME_GOLD"    = "PRIMAS_RENTAS_ENDOSOS_GOLD"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/primasrentasendosos_gold_dev_reports.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }
////END NEW JOBS////

      //job validador archivo Oro
      job_files_gold_source = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-files-gold-source"
        job_description = "Job to Files Gold Source"
        role            = "gold_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
          "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = var.gold_bucket_id
          "--BUCKET_SOURCE"      = "alfa-datalake-qa-bronce"
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
          "--DB_NAME"            = "Files"
          "--DB_SCHEMA"          = "Files"
          "--PERIOD"             = "202508"
          "--LOAD_MODE"          = "truncate" 
          "--FILES" = jsonencode({
                      NIIF17_ULAES_VIDA      = "ULAES_VIDA"
                      NIIF17_ULAES_GENERALES = "ULAES_GENERALES"
                      NIIF17_PREVISIONAL     = "ARCHIVO_CESION_PREVISIONALES"
                    })
          "--FILES_TOTAL" = jsonencode({
                    NIIF17_PREVISIONAL = "ARCHIVO_CESION_PREVISIONALES_CALCULADOS"
                  })
          "--TABLES_PARAMS"  = jsonencode({ "artefacto": "datalake-dev-artefacto", "acn": "datalake-dev-artefacto-concepto-nota-params", "concepto": "datalake-dev-concepto", "nota": "datalake-dev-nota"  })
          
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/files_gold_dev_source.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }
      //end validador archivo Oro

      //Jobs Parametros Funcionalidad #1 (params_prm_qa_historic)
 job_params_prm_qa_historic = {
        create          = true
        job_name        = "${var.prefix}-${terraform.workspace}-prm-historic"
        job_description = "Job to Parameters Funcitions 1"
        role            = "gold_layer"
        glue_version    = "4.0"
        default_arguments = {
          "--enable-metrics"                   = "true"
          "--enable-continuous-cloudwatch-log" = "true"
          "--enable-job-insights"              = "true"
          "--enable-spark-ui"                  = "true"
          "--enable-glue-datacatalog"          = "true"
          "--job-language"                     = "python"
          "--job-bookmark-option"              = "job-bookmark-disable"
          "--spark-event-logs-path"            = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/sparkHistoryLogs/"
          "--TempDir"                          = "s3://aws-glue-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/temporary/"
          "--extra-py-files" = format("%s,%s,%s,%s",
            "s3://${var.assets_bucket_id}/glue_resources/niff/libraries/commons.zip",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/openpyxl-3.0.10-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/pyxlsb-1.0.8-py2.py3-none-any.whl",
            "s3://${var.assets_bucket_id}/glue_resources/wheelhouse/et_xmlfile-2.0.0-py3-none-any.whl")
          "--BUCKET_NAME_ASSETS" = var.assets_bucket_id
          "--BUCKET_NAME"        = "alfa-datalake-qa-prm"
          "--CERTIFICATE"        = "False"
          "--DB_CATALOG_GLUE"    = "${var.prefix}-${terraform.workspace}-prm"
          "--DB_NAME"            = "ALFAPRD"
          "--DB_SCHEMA"          = "GENERAL"
          "--PERIOD"             = "0"
          "--TABLE_NAME_GOLD"    = "IPCTASATECNICA_PRM_GOLD" 
          "--VAL_PERIOD"         = "0"
        }

        worker_type       = "G.1X"
        number_of_workers = 10
        max_retries       = 0
        timeout           = 2880

        command = {
          name            = "glueetl"
          python_version  = 3
          script_location = "s3://${var.assets_bucket_id}/glue_resources/niff/jobs/params_prm_dev_historic.py"
        }

        execution_property = {
          max_concurrent_runs = "1"
        }
      }
      //end Funcionalidad Parametros #1 (params_prm_qa_historic)

      used_jobs = []
      #####################################################################
      # Connection association
      #####################################################################
      job_connections = {
        job_alfprd_general_bronce_extract = [
          "connection_alfaprd_dev",
          "connection_alfaprd_qa",
          "connection_alfaprd_cer"
        ]
        job_alfprd_prv_bronce_extract = [
          "connection_alfaprd_dev",
          "connection_alfaprd_qa",
          "connection_alfaprd_cer"
        ]
        job_alfprd_arpprod_bronce_extract = [
          "connection_alfaprd_dev",
          "connection_alfaprd_qa",
          "connection_alfaprd_cer"
        ]
      }
    }
    dev = {
      used_jobs = [
        "job_alfprd_general_bronce_extract",
        "job_alfprd_prv_bronce_extract",
        "job_alfprd_arpprod_bronce_extract",
        "job_alfprd_general_bronce_quality",
        "job_alfprd_prv_bronce_quality",
        "job_alfprd_arpprod_bronce_quality",
        "job_auxiliofunerario_silver_transformation",
        "job_primasrentas_silver_transformation",
        "job_reserva_arpprod_silver_transformation",
        "job_reserva_general_silver_transformation",
        "job_reserva_prv_silver_transformation",
        "job_auxiliofunerario_gold_reports",
        "job_primasrentas_gold_reports",
        "job_reserva_arp_gold_reports",
        "job_reserva_rvi_gold_reports"
      ]
    }
    qa = {
      used_jobs = [
        "job_alfprd_general_bronce_extract",
        "job_alfprd_prv_bronce_extract",
        "job_alfprd_arpprod_bronce_extract",
        "job_alfprd_general_bronce_quality",
        "job_alfprd_prv_bronce_quality",
        "job_alfprd_arpprod_bronce_quality",
        "job_auxiliofunerario_silver_transformation",
        "job_primasrentas_silver_transformation",
        "job_reserva_arpprod_silver_transformation",
        "job_reserva_general_silver_transformation",
        "job_reserva_prv_silver_transformation",
        "job_auxiliofunerario_gold_reports",
        "job_primasrentas_gold_reports",
        "job_reserva_arp_gold_reports",
        "job_reserva_rvi_gold_reports",
        "job_files_bronce_extract",
        "job_acsele_alfa_bronce_granular_extract",
        "job_acsele_alfa_bronce_quality",
        "job_pcrtradicional_silver_transformation",
        "job_primasarl_silver_transformation",
        "job_primasarl_gold_reports",
        "job_files_bronce_extract_quality",
        "job_files_gold_source",
        "job_primasrentasendosos_gold_reports",
        "job_params_prm_qa_historic"
      ]
      job_connections = {
        job_alfprd_general_bronce_extract = [
          "connection_alfaprd_dev",
          "connection_alfaprd_qa",
          "connection_alfaprd_cer"
        ]
        job_alfprd_prv_bronce_extract = [
          "connection_alfaprd_dev",
          "connection_alfaprd_qa",
          "connection_alfaprd_cer"
        ]
        job_alfprd_arpprod_bronce_extract = [
          "connection_alfaprd_dev",
          "connection_alfaprd_qa",
          "connection_alfaprd_cer"
        ]
      }
    }
    prd = {
      used_jobs = [
        "job_alfprd_general_bronce_extract",
        "job_alfprd_general_bronce_quality",
        "job_auxiliofunerario_silver_transformation",
        "job_auxiliofunerario_gold_reports",
      ]
      job_connections = {
        job_alfprd_general_bronce_extract = [
          "connection_alfaprd_prd"
        ]
      }
    }
  }
  environmentvars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace       = merge(local.env["default"], local.env[local.environmentvars])
}
