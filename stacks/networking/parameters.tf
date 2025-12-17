locals {
  env = {
    default = {
      tags = {
        Environment = terraform.workspace
        Protected   = false
        Layer       = "Networking"
        Project     = var.project
      }

      vpc = {
        name               = "${var.prefix}-${terraform.workspace}-vpc"
        cidr               = "10.10.0.0/16"
        azs                = ["${var.region}a", "${var.region}b"]
        public_subnets     = ["10.10.0.0/24", "10.10.1.0/24"]
        private_subnets    = ["10.10.10.0/24", "10.10.11.0/24"]
        enable_nat_gateway = true
        single_nat_gateway = true
      }
    }
    dev = {}
    qa  = {}
    prd = {
      tags = { Protected = true }
      vpc = {
        single_nat_gateway = false # NAT por AZ en prod (más HA)
      }
    }
  }

  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}
