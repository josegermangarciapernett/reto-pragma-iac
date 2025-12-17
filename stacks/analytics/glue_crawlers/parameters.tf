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
            ]
          },
          {
            sid = "AllowLakeformationActions"
            actions = [
              "lakeformation:*"
            ]
            effect    = "Allow"
            resources = ["*"]
          }
        ]
      }

      crawler_roles = {
        bronce_layer = {
          create_role       = true
          role_name         = "${var.prefix}-${terraform.workspace}-niif-crawler-bronce-layer"
          role_requires_mfa = false
          trusted_role_services = [
            "glue.amazonaws.com"
          ]
          inline_policy           = "general"
          custom_role_policy_arns = []
        }
        silver_layer = {
          create_role       = true
          role_name         = "${var.prefix}-${terraform.workspace}-niif-crawler-silver-layer"
          role_requires_mfa = false
          trusted_role_services = [
            "glue.amazonaws.com"
          ]
          inline_policy           = "general"
          custom_role_policy_arns = []
        }
        gold_layer = {
          create_role       = true
          role_name         = "${var.prefix}-${terraform.workspace}-niif-crawler-gold-layer"
          role_requires_mfa = false
          trusted_role_services = [
            "glue.amazonaws.com"
          ]
          inline_policy           = "general"
          custom_role_policy_arns = []
        }
      }
      #####################################################################
      # glue_crawlers module
      #####################################################################
      alfprd_arpprod_bronce = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-alfprd-arpprod-bronce"
        crawler_description = "Glue crawler for save data on data catalog from s3 arpprod"
        database            = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "alfaprd_arpprod_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/GAR_TIPOS_ENDOSOS_ARP/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/PAR_ENDOSOS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/PAR_POLIZAS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/HIST_DATOS_INVALIDEZ_MUERTE/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/SAR_RESERVA_PCJ_AMORTIZACION/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/SAR_SINIESTROS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/IND_DATOS_RESERVAS_SINIESTROS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/PAR_TRABAJADORES/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/SAR_AUDITORIA_MEDICA/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/SAR_BENEFICIARIOS_SINIESTROS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/SAR_DATOS_INVALIDEZ_MUERTE/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/HIST_SAR_PCL_PENSION/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/PAR_AUTOLIQUIDACION_SUCURSAL/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/PAR_AUTOLIQUIDACION_TRABAJADOR/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/ARPPROD/SAR_PAGOS_COBERTURAS/" },
        ]

        role = "bronce_layer"
      }

      alfprd_general_bronce = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-alfprd-general-bronce"
        crawler_description = "Glue crawler for save data on data catalog from s3 general"
        database            = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "alfaprd_general_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/ANP_PENSIONES/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/ANP_MOVIMIENTOS_PAGO/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/ANP_DETALLE_SOLICITUDES_GIRO/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/ACU_PERSONAS_NATURALES/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/ANP_DISTRIBUCION_VIG_PENSION/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/ANP_PENSIONADO_NOVEDAD/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/ANP_PERIODO_SOLICITUDES_GIRO/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/CGR_CONCEPTOS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/CGR_TIPOS_ENDOSOS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/CGR_TIPOS_IDENTIFICACIONES/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/CGR_ORIGENES/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/CGR_EQUIVALENCIA_TIPOS_ID/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/CGR_PARENTESCOS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/CGR_ESTADOS_PERSONAS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/RVA_RESERVA_MATEMATICA_TRANSIC/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/PGR_SALARIOS_MINIMOS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/GENERAL/ANP_IPC" },
        ]

        role = "bronce_layer"
      }

      alfprd_prv_bronce = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-alfprd-prv-bronce"
        crawler_description = "Glue crawler for save data on data catalog from s3 prv"
        database            = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "alfaprd_prv_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/PRV_BENEFICIARIOS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/PRV_ENDOSOS_POINT/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/PRV_RENTAS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/PRV_RENTAS_APROBADAS_OBP/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/CRV_PORCENTAJES_AMORTIZACION/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/PRV_ENDOSO_RECAUDOS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/SPR_SINIESTROS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/PRV_SALDOS_MATEMATICA/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/PRV_RENTAS_NOTAS/" },
          { path = "s3://${var.bronce_bucket_id}/ALFAPRD/PRV/CRV_CALCULOS_2/" },
          
        ]

        role = "bronce_layer"
      }
////crawlers prc //
////ACTUALIZADO 5-09-2025   despliegue
 alfprd_pcr_tradicional_bronce = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-alfprd_pcr_tradicional_bronce"
        crawler_description = "Glue crawler alfprd pcr tradicional bronce dev crawler"
        database            = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "acsele_alfa_full_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/AGREGATEDPOLICY/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/COBERTURA/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/CONTEXTOPERATION/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/COVERAGEDCO/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/FINANCIALPLANDCO/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PARTICIPACIONINTERMEDIARIOS/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PERSONAJURIDICA/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PREAGREEMENT/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PREPOLICY/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PREPRODUCT/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PRETHIRDPARTY/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PRODUCT/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PROPERTY/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REASEGURADOR/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATION/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATIONCOMPONENT/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATIONDETAIL/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATIONGROUPINFO/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/RI_PARTICIPATION/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/RISKUNITDCO/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/RPND13Y/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STAG_AGREEMENTVERSION/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STCA_DOCTYPE/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STPO_POLICYPARTICIPATION/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STPO_POLICYPARTICIPATIONDCO/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STPS_AGREEMENTSTATICDAT/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STPS_RELATIONAGREEMENTPOLICY/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STST_SYSTEMPROPERTY/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STTE_THIRDPARTY/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STTS_ROLE/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/TDCALIFICACIONRIESGO/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/THIRDPARTYROLE/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/UAADETAIL/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/POLICYDCO/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/THIRDPARTYMOVEMENTPOLICY/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/RI_REINSURANCEGROUP/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/OPENITEM/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STRI_REINSURANCEKIND/" },
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PRERISKUNITS/" }, 
        { path = "s3://${var.bronce_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATIONPROPERTY/" },
        ]
        role = "bronce_layer"
      }
//endcrawles prc

///crawlers : files_bronce_dev_crawler /22/07/2025

   files_bronce = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-files-bronce"
        crawler_description = "Glue crawler for Files Bronce Prophet"
        database            = "${var.prefix}-${terraform.workspace}-bronce-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "files_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          
          { path = "s3://${var.bronce_bucket_id}/NIIF17_PREVISIONAL/ARCHIVO_CESION_PREVISIONALES/" },
          { path = "s3://${var.bronce_bucket_id}/NIIF17_ULAES_VIDA/ULAES_VIDA/" },
          { path = "s3://${var.bronce_bucket_id}/NIIF17_ULAES_GENERALES/ULAES_GENERALES/" },
          { path = "s3://${var.bronce_bucket_id}/NIIF17_CAMPOS_UNICA_VEZ/CAMPOS_UNICA_VEZ/" },
          { path = "s3://${var.bronce_bucket_id}/NIIF17_IPCTASATECNICA/IPCTASATECNICA/" },
          { path = "s3://${var.bronce_bucket_id}/NIIF17_PRIMALIQUIDEZ/PRIMALIQUIDEZ/" },
          { path = "s3://${var.bronce_bucket_id}/NIIF17_GASTOS/GASTOS/" },

        ]
        role = "bronce_layer"
      }


 logs_validation = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-logs_validation"
        crawler_description = "Glue crawler for Logs Validations Bronce Prophet"
        database            = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "files_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.silver_bucket_id}/LOGS/FILES_VALIDATION/" },
        ]
        role = "silver_layer"
      }
//end crawlers



//crawler prc silver ACTUALIZADO 5-09-2025
   pcr-tradicional_silver_crawler = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-pcr-tradicional_silver_crawler"
        crawler_description = "Glue crawler for save data on data catalog from s3 arpprod silver"
        database            = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "acsele_alfa_full_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/AGREGATEDPOLICY/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/COBERTURA/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/CONTEXTOPERATION/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/COVERAGEDCO/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/FINANCIALPLANDCO/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PARTICIPACIONINTERMEDIARIOS/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PERSONAJURIDICA/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PREAGREEMENT/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PREPOLICY/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PREPRODUCT/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PRETHIRDPARTY/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PRODUCT/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PROPERTY/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REASEGURADOR/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATION/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATIONCOMPONENT/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATIONDETAIL/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATIONGROUPINFO/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/RI_PARTICIPATION/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/RISKUNITDCO/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/RPND13Y/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STAG_AGREEMENTVERSION/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STCA_DOCTYPE/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STPO_POLICYPARTICIPATION/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STPO_POLICYPARTICIPATIONDCO/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STPS_AGREEMENTSTATICDAT/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STPS_RELATIONAGREEMENTPOLICY/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STST_SYSTEMPROPERTY/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STTE_THIRDPARTY/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STTS_ROLE/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/TDCALIFICACIONRIESGO/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/THIRDPARTYROLE/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/UAADETAIL/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/POLICYDCO/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/THIRDPARTYMOVEMENTPOLICY/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/RI_REINSURANCEGROUP/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/OPENITEM/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/STRI_REINSURANCEKIND/" },
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/PRERISKUNITS/" }, 
          { path = "s3://${var.silver_bucket_id}/ACSELE/ACSELE_ALFA_FULL/REINSURANCEOPERATIONPROPERTY/" },
         ]
        role = "silver_layer"
      }
//end prc silver
      alfprd_arpprod_silver = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-alfprd-arpprod-silver"
        crawler_description = "Glue crawler for save data on data catalog from s3 arpprod silver"
        database            = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "alfaprd_arpprod_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_HIST_DATOS_INVALIDEZ_MUERTE/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_PAR_TRABAJADORES/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_SAR_AUDITORIA_MEDICA/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_SAR_BENEFICIARIOS_SINIESTROS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_SAR_SINIESTROS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_IND_DATOS_RESERVAS_SINIESTROS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_SAR_RESERVA_PCJ_AMORTIZACION/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_HIST_SAR_PCL_PENSION/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_SAR_DATOS_INVALIDEZ_MUERTE/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_PAR_POLIZAS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_GAR_TIPOS_ENDOSOS_ARP/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_PAR_ENDOSOS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_PAR_AUTOLIQUIDACION_TRABAJADOR/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/ARPPROD/SILVER_PAR_AUTOLIQUIDACION_SUCURSAL/" },
        ]

        role = "silver_layer"
      }

      alfprd_general_silver = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-alfprd-general-silver"
        crawler_description = "Glue crawler for save data on data catalog from s3 general silver"
        database            = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "alfaprd_general_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ACU_PERSONAS_NATURALES/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_DETALLE_SOLICITUDES_GIRO/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_DISTRIBUCION_VIG_PENSION/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_PENSIONADO_NOVEDAD/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_PENSIONES/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_PERIODO_SOLICITUDES_GIRO/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_CGR_CONCEPTOS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_CGR_ORIGENES/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_CGR_TIPOS_IDENTIFICACIONES/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_CGR_EQUIVALENCIA_TIPOS_ID/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_CGR_ESTADOS_PERSONAS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_CGR_PARENTESCOS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_IPC/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_RVA_RESERVA_MATEMATICA_TRANSIC/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_PGR_SALARIOS_MINIMOS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_CGR_TIPOS_ENDOSOS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_MOVIMIENTOS_PAGO/" },
         
        ]

        role = "silver_layer"
      }

      alfprd_prv_silver = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-alfprd-prv-silver"
        crawler_description = "Glue crawler for save data on data catalog from s3 prv silver"
        database            = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "alfaprd_prv_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/PRV/SILVER_PRV_RENTAS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/PRV/SILVER_PRV_ENDOSOS_POINT/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/PRV/SILVER_PRV_SALDOS_MATEMATICA/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/PRV/SILVER_PRV_BENEFICIARIOS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/PRV/SILVER_PRV_RENTAS_NOTAS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/PRV/SILVER_PRV_RENTAS_APROBADAS_OBP/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/PRV/SILVER_SPR_SINIESTROS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/PRV/SILVER_CRV_CALCULOS_2/" },
          
        ]

        role = "silver_layer"
      }

      niff_gold = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-niff-gold"
        crawler_description = "Glue crawler for save data on data catalog from s3 use cases niif"
        database            = "${var.prefix}-${terraform.workspace}-gold-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "niif_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/AUXILIOS_FUNERARIOS_GOLD/" },
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/PRIMAS_RENTAS_RENTAS_GOLD/" },
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/RESERVA_ARP_GOLD/" },
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/PRIMAS_ARL_GOLD/" },
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/PRIMAS_RENTAS_ENDOSOS_GOLD/" },
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/RESERVA_RVI_GOLD/" },
        ]

        role = "gold_layer"
      }

        ///files_gold_dev_crawler
        files_gold = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-files-gold"
        crawler_description = "Glue crawler for files gold NIFF"
        database            = "${var.prefix}-${terraform.workspace}-gold-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "niif_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/ARCHIVO_CESION_PREVISIONALES_GOLD/" },
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/ARCHIVO_CESION_PREVISIONALES_CALCULADOS_GOLD/" },
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/ULAES_VIDA_GOLD/" },
          { path = "s3://${var.gold_bucket_id}/GOLD/NIIF/ULAES_GENERALES_GOLD/" },
        ]

        role = "gold_layer"
      }
        ///end : files_gold_dev_crawler


        //new crawler PRM
          niff_prm = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-niff-prm"
        crawler_description = "Glue crawler Parameters NIFF"
        database            = "datalake-qa-prm"
        role                = null
        schedule            = null
        table_prefix        = "niif_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://alfa-datalake-qa-prm/GOLD/NIIF/ARCHIVO_CESION_PREVISIONALES_GOLD/" },
          { path = "s3://alfa-datalake-qa-prm/GOLD/NIIF/GOLD_GASTOS/" },
          { path = "s3://alfa-datalake-qa-prm/GOLD/NIIF/GOLD_PRIMALIQUIDEZ/" },
        
        ]

        role = "gold_layer"
      }
        //end crawler PRM


    }
    dev = {
      used_crawlers = [
        "alfprd_arpprod_bronce",
        "alfprd_general_bronce",
        "alfprd_prv_bronce",
        "alfprd_arpprod_silver",
        "alfprd_general_silver",
        "alfprd_prv_silver",
        "niff_gold"
      ]
    }
    qa = {
      used_crawlers = [
        "alfprd_arpprod_bronce",
        "alfprd_general_bronce",
        "alfprd_prv_bronce",
        "alfprd_arpprod_silver",
        "alfprd_general_silver",
        "alfprd_prv_silver",
        "niff_gold",
        "alfprd_pcr_tradicional_bronce",
        "pcr-tradicional_silver_crawler",
        "files_bronce",
        "logs_validation",
        "files_gold",
        "niff_prm"
      ]
    }
    prd = {
      used_crawlers = [
        "alfprd_general_bronce",
        "alfprd_general_silver",
        "niff_gold"
      ]

      alfprd_general_silver = {
        create              = true
        crawler_name        = "${var.prefix}-${terraform.workspace}-alfprd-general-silver"
        crawler_description = "Glue crawler for save data on data catalog from s3 general silver"
        database            = "${var.prefix}-${terraform.workspace}-silver-catalog-db"
        role                = null
        schedule            = null
        table_prefix        = "alfaprd_general_"
        configuration = jsonencode(
          {
            Version              = 1
            CreatePartitionIndex = true
          }
        )
        recrawl_policy = {
          recrawl_behavior = "CRAWL_EVERYTHING"
        }
        schema_change_policy = {
          delete_behavior = "DEPRECATE_IN_DATABASE"
          update_behavior = "UPDATE_IN_DATABASE"
        }
        lineage_configuration = {
          crawler_lineage_settings = "DISABLE"
        }

        s3_target = [
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_DETALLE_SOLICITUDES_GIRO/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_DISTRIBUCION_VIG_PENSION/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_PENSIONADO_NOVEDAD/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_PENSIONES/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_ANP_PERIODO_SOLICITUDES_GIRO/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_CGR_CONCEPTOS/" },
          { path = "s3://${var.silver_bucket_id}/ALFAPRD/GENERAL/SILVER_CGR_ORIGENES/" },
        ]

        role = "silver_layer"
      }
    }
  }
  environmentvars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace       = merge(local.env["default"], local.env[local.environmentvars])
}
