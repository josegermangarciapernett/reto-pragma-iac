/*
* # Stack: Aurora PostgreSQL
* - terraform-aws-modules/rds-aurora/aws
*/

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.10.0"

  name           = local.workspace.aurora.name
  engine         = "aurora-postgresql"
  engine_mode    = local.workspace.aurora.engine_mode # provisioned o serverless
  vpc_id         = local.workspace.aurora.vpc_id
  subnets        = local.workspace.aurora.private_subnet_ids

  master_username = local.workspace.aurora.master_username
  database_name   = local.workspace.aurora.database_name

  storage_encrypted = true

  # Serverless v2 (si aplica)
  serverlessv2_scaling_configuration = local.workspace.aurora.serverlessv2_scaling

  tags = local.workspace.tags
}
