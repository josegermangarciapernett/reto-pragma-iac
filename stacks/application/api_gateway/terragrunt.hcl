include "root" {
  path = find_in_parent_folders()
}

# dependency "serverless" {
#   config_path = "${get_parent_terragrunt_dir("root")}/stacks/serverless/audit"
#   mock_outputs = {
#     lf_logs_get_invoke_arn   = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:082294412983:function:dev-sipren-logs-get-service/invocations"
#     lf_events_get_invoke_arn = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:082294412983:function:dev-sipren-events-get-service/invocations"
#   }
#   mock_outputs_merge_strategy_with_state = "shallow"
# }

inputs = {
#   nlb_arn       = dependency.core.outputs.nlb_arn
#   nlb_dns       = dependency.core.outputs.nlb_dns
#   kms_key_id    = dependency.core.outputs.infra_key_arn
#   user_pool_arn = dependency.core.outputs.user_pool_arn
#   acm_cert_arn  = dependency.core.outputs.acm_cert_arn
#   domain_name   = dependency.core.outputs.domain_name

#   lf_logs_get_invoke_arn   = dependency.serverless.outputs.lf_logs_get_invoke_arn
#   lf_events_get_invoke_arn = dependency.serverless.outputs.lf_events_get_invoke_arn
}
