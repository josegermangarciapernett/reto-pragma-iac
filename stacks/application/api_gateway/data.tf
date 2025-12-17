data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "template_file" "oas_definition" {
  template = file(local.workspace["definition_path"])

  vars = {
    api_title       = local.workspace["api_name"]
    api_version     = "1.0.0"
    api_description = "API Rest to NIIF proyect"

    post_login_lambda_uri    = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:533267205627:function:niif-post-login/invocations"
    certification_lambda_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:533267205627:function:niif-cerfication/invocations"

    user_pool_arn = "arn:aws:cognito-idp:us-east-1:533267205627:userpool/us-east-1_gg6kZ9C4O"
  }
}
