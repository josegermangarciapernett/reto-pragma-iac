locals {
  env = {
    default = {
      tags = {
        Environment = terraform.workspace
        Protected   = false
        Layer       = "Database"
        Project     = var.project
      }

      aurora = {
        name              = "${var.prefix}-${terraform.workspace}-aurora"
        vpc_id            = ""
        private_subnet_ids = []

        engine_mode      = "provisioned" # cambia a serverless si lo quieres
        database_name    = "appdb"
        master_username  = "appadmin"

        serverlessv2_scaling = {
          min_capacity = 0.5
          max_capacity = 8
        }
      }
    }
    dev = {
      aurora = {
        serverlessv2_scaling = { min_capacity = 0.5, max_capacity = 2 }
      }
    }
    qa = {}
    prd = {
      tags = { Protected = true }
      aurora = {
        serverlessv2_scaling = { min_capacity = 1, max_capacity = 16 }
      }
    }
  }

  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
