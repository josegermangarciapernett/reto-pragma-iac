output "ssm_parameters" {
  description = "Map with the parameter store ids"
  value       = { for ps_key, ps in module.ssm_parameters : ps_key => ps.ssm_parameter_name }
}
