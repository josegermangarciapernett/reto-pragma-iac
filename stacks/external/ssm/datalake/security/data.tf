data "aws_ssm_parameter" "security" {
  name = "/datalake/${terraform.workspace}/outputs/security"
}
