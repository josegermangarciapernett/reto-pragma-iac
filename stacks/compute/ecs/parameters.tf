locals {
  env = {
    default = {
      tags = {
        Environment = terraform.workspace
        Protected   = false
        Layer       = "Compute"
        Project     = var.project
      }

      ecs = {
        cluster_name       = "${var.prefix}-${terraform.workspace}-cluster"
        private_subnet_ids = []
        security_group_ids = []
        target_group_arn   = ""

        cpu           = 512
        memory        = 1024
        desired_count = 2

        container_port = 8080
        image          = "public.ecr.aws/nginx/nginx:latest" # placeholder infra-only

        log_group = "/ecs/${var.prefix}/${terraform.workspace}/api"

        environment = [
          { name = "ENV", value = terraform.workspace }
        ]

        # Secrets Manager
        secrets = [
          # { name = "DB_PASSWORD", valueFrom = "arn:aws:secretsmanager:..." }
        ]
      }
    }

    dev = {}
    qa  = {}
    prd = {
      tags = { Protected = true }
      ecs = {
        desired_count = 3
        cpu           = 1024
        memory        = 2048
      }
    }
  }

  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
