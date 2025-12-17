output "lambda_version_ssm_names" {
  description = "Map with the parameter store ids that store the lambda versions"
  value       = { for ps_key, ps in module.ssm_ps_lambda_versions : ps_key => ps.ssm_parameter_name }
}

output "lambda_ecr_urls" {
  description = "Map with the ECR repository URLs"
  value       = { for ecr_key, ecr in module.lambda_ecr : ecr_key => ecr.repository_url }
}
