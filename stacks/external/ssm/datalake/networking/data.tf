data "aws_ssm_parameter" "network" {
  name = "/${var.prefix}/${terraform.workspace}/networking/parameters"
}

data "aws_ssm_parameter" "networking" {
  name = "/datalake/${terraform.workspace}/outputs/networking"
}
