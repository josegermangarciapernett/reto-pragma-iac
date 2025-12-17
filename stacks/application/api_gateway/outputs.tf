# output "api_id" {
#   description = "The ID of the REST API"
#   value       = module.api_gtw.id
# }

# output "api_arn" {
#   description = "The ARN of the REST API"
#   value       = module.api_gtw.arn
# }

# output "stage_arn" {
#   description = "The ARN of the gateway stage"
#   value       = module.api_gtw.stage_arn
# }

# output "api_invoke_url" {
#   description = "The URL to invoke the REST API"
#   value       = module.api_gtw.invoke_url
# }

# output "regional_domain_name" {
#   description = "Hostname for the custom domain's regional endpoint"
#   value       = try(aws_api_gateway_domain_name.this[0].regional_domain_name, "")
# }

# output "api_wafv2_id" {
#   description = "The ID of the WAF WebACL."
#   value       = module.api_wafv2.id
# }

# output "api_wafv2_arn" {
#   description = "The ARN of the WAF WebACL."
#   value       = module.api_wafv2.arn
# }
