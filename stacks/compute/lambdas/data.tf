data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# data "aws_ssm_parameter" "smb_lambda_version" {
#   name = "/${var.prefix}/${terraform.workspace}/lambda/sbm/version"

#   depends_on = [module.smb_lambda_version]
# }

# data "aws_ssm_parameter" "contingency_lambda_version" {
#   name = "/${var.prefix}/${terraform.workspace}/lambda/contingency/version"

#   depends_on = [module.contingency_lambda_version]
# }
