output "ps_destination_names" {
  description = "Names of connection parameters"
  value       = { for parameter_key, parameters in module.ssm_ps_connections : parameter_key => parameters.ssm_parameter_name }
}

output "connection_names" {
  description = "Glue Crawler names"
  value       = { for connection_key, connection in module.glue_connections : connection_key => connection.name }
}
