locals {
  env = {
    default = {
      create_resource_group = false
      enable_app_insights   = false
      description           = "Resource group for ${var.project} Resources for ${terraform.workspace}"
      resource_group_name   = "${var.project}-${terraform.workspace}"
      resource_tags_filters = {
        ResourceTypeFilters = ["AWS::AllSupported"],
        TagFilters = [
          {
            Key    = "Project",
            Values = [var.required_tags["Project"]]
          }
        ]
      }
      tags = {
        Environment = terraform.workspace
        Layer       = "Operations"
      }
    }
    dev = {
      create_resource_group = true
      enable_app_insights   = true
    }
    qa = {
      create_resource_group = true
      enable_app_insights   = true
    }
    prd = {
      create_resource_group = true
      enable_app_insights   = true
    }
  }
  # Set workspace parameters for the associated environment
  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
