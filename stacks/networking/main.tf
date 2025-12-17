/*
* # Stack: Networking (VPC)
* - terraform-aws-modules/vpc/aws
*/

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = local.workspace.vpc.name
  cidr = local.workspace.vpc.cidr

  azs             = local.workspace.vpc.azs
  private_subnets = local.workspace.vpc.private_subnets
  public_subnets  = local.workspace.vpc.public_subnets

  enable_nat_gateway = local.workspace.vpc.enable_nat_gateway
  single_nat_gateway = local.workspace.vpc.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.workspace.tags
}
