locals {
  env = {
    default = {
      tags = {
        Environment = terraform.workspace
        Protected   = false
        Layer       = "Cache"
        Project     = var.project
      }

      redis = {
        subnet_group_name  = "${var.prefix}-${terraform.workspace}-redis-subnets"
        replication_group_id = "${var.prefix}-${terraform.workspace}-redis"
        private_subnet_ids = []
        security_group_ids = []

        node_type = "cache.t4g.small"
        num_cache_clusters = 1
        multi_az_enabled   = false
        automatic_failover_enabled = false
      }
    }
    prd = {
      tags = { Protected = true }
      redis = {
        num_cache_clusters = 2
        multi_az_enabled   = true
        automatic_failover_enabled = true
      }
    }
  }

  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
