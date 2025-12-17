locals {
  env = {
    default = {
      #############################################################################
      # Commons Parameters
      #############################################################################
      export_parameters = false
      tags = {
        Environment = terraform.workspace
        Layer       = "Analytics"
      }
      #############################################################################
      # ssm_ps_connections Module
      #############################################################################
      connection_destinations = {
        alfaprd = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/alfaprd/connections"
          description = "List of connections to alfaprd"
        }
      }
      #############################################################################
      # glue_connections Module
      #############################################################################
      connection_alfaprd_dev = {
        create                 = true
        connection_name        = "${var.prefix}-${terraform.workspace}-alfaprd-dev-connection"
        connection_description = "Glue connection to alfaprd dev"
        connection_type        = "JDBC"
        connection_properties = {
          JDBC_CONNECTION_URL = "jdbc:oracle:thin:@//10.61.57.98:5521/ALPRODAC"
          SECRET_ID           = try(var.jdbc_secret_ids["alfaprd_dev"], "")
        }
        physical_connection_requirements = {
          security_group_id_list = [var.glue_connection_sg_id]
          availability_zone      = var.private_azs[0]
          subnet_id              = var.private_subnet_ids[0]
        }
      }

      connection_alfaprd_qa = {
        create                 = true
        connection_name        = "${var.prefix}-${terraform.workspace}-alfaprd-qa-connection"
        connection_description = "Glue connection to alfaprd qa"
        connection_type        = "JDBC"
        connection_properties = {
          JDBC_CONNECTION_URL = "jdbc:oracle:thin:@//10.61.57.162:5521/ALFAPROD"
          SECRET_ID           = try(var.jdbc_secret_ids["alfaprd_qa"], "")
        }
        physical_connection_requirements = {
          security_group_id_list = [var.glue_connection_sg_id]
          availability_zone      = var.private_azs[0]
          subnet_id              = var.private_subnet_ids[0]
        }
      }

      ///NEW GLUE CONECTION NUEVOS AMBIENTES
      connection_alfaprd_pre = {
        create                 = true
        connection_name        = "${var.prefix}-${terraform.workspace}-alfaprd-pre-connection"
        connection_description = "Glue connection to alfaprd pre"
        connection_type        = "JDBC"
        connection_properties = {
          JDBC_CONNECTION_URL = "jdbc:oracle:thin:@//10.61.57.98:5521/ALPRODAC"
          SECRET_ID           = try(var.jdbc_secret_ids["alfaprd_pre"], "")
        }
        physical_connection_requirements = {
          security_group_id_list = [var.glue_connection_sg_id]
          availability_zone      = var.private_azs[0]
          subnet_id              = var.private_subnet_ids[0]
        }
      }
      //END NEW GLUE

      connection_alfaprd_cer = {
        create                 = true
        connection_name        = "${var.prefix}-${terraform.workspace}-alfaprd-cer-connection"
        connection_description = "Glue connection to alfaprd cer"
        connection_type        = "JDBC"
        connection_properties = {
          JDBC_CONNECTION_URL = "jdbc:oracle:thin:@//10.61.57.98:5521/ALPRODAC"
          SECRET_ID           = try(var.jdbc_secret_ids["alfaprd_cer"], "")
        }
        physical_connection_requirements = {
          security_group_id_list = [var.glue_connection_sg_id]
          availability_zone      = var.private_azs[0]
          subnet_id              = var.private_subnet_ids[0]
        }
      }

      connection_alfaprd_prd = {
        create                 = true
        connection_name        = "${var.prefix}-${terraform.workspace}-alfaprd-prd-connection"
        connection_description = "Glue connection to alfaprd prd"
        connection_type        = "JDBC"
        connection_properties = {
          JDBC_CONNECTION_URL = "jdbc:oracle:thin:@//10.61.56.199:5521/ALPRODAC"
          SECRET_ID           = try(var.jdbc_secret_ids["alfaprd_prd"], "")
        }
        physical_connection_requirements = {
          security_group_id_list = [var.glue_connection_sg_id]
          availability_zone      = var.private_azs[0]
          subnet_id              = var.private_subnet_ids[0]
        }
      }
    }
    dev = {
      used_connections = [
        "connection_alfaprd_dev",
        "connection_alfaprd_qa",
        "connection_alfaprd_cer",
        "connection_alfaprd_pre",
      ]
    }
    qa = {
      used_connections = [
        "connection_alfaprd_dev",
        "connection_alfaprd_qa",
        "connection_alfaprd_cer",
        "connection_alfaprd_pre",
      ]
    }
    prd = {
      used_connections = [
        "connection_alfaprd_prd",
      ]
    }
  }
  environmentvars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace       = merge(local.env["default"], local.env[local.environmentvars])
}
