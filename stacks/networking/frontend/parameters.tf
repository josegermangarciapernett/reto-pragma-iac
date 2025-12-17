locals {
  env = {
    default = {
      tags = {
        Environment = terraform.workspace
        Protected   = false
        Layer       = "Frontend"
        Project     = var.project
      }

      frontend = {
        bucket_name    = "${var.prefix}-${terraform.workspace}-frontend"
        force_destroy  = true
        acm_arn        = ""  # lo inyectas por terragrunt o var si prefieres
        waf_web_acl_id = ""  # idem
        cf_comment     = "${var.prefix}-${terraform.workspace}-cloudfront"
      }

    alb = {
        name             = "${var.prefix}-${terraform.workspace}-alb"
        vpc_id           = ""   # dependency terragrunt (vpc)
        public_subnet_ids = []  # dependency terragrunt (vpc)
        security_group_ids = [] # sg del alb
        certificate_arn  = ""   # ACM
        target_port      = 8080
        healthcheck_path = "/health"
      }
    }
    dev = {}
    qa  = {}
    prd = {
      tags = { Protected = true }
      frontend = {
        force_destroy = false
      }
    }
  }

  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
