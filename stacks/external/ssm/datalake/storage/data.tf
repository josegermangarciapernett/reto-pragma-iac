data "aws_ssm_parameter" "storage" {
  name = "/datalake/${terraform.workspace}/outputs/storage"
}
