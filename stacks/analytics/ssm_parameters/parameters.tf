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
      # ssm_paramenters Module
      #############################################################################
      parameters = {
        deslizamiento = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/pragma/deslizamiento"
          description = "Parameters store to store data parameters"
        }
        gastos = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/pragma/gastos"
          description = "Parameters store to store data parameters"
        }
        tasa_fac_seg = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/pragma/tasa_fac_seg"
          description = "Parameters store to store data parameters"
        }
      }
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
