output "vpc_id" {
  description = "The ID of the VPC"
  value       = local.workspace["vpc_id"]
}

output "public_azs" {
  description = "List of availability zone of public subnets"
  value       = local.workspace["public_azs"]
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = local.workspace["public_subnet_ids"]
}

output "public_route_table_ids" {
  description = "List of IDs of public toute tables"
  value       = local.workspace["public_route_table_ids"]
}

output "private_azs" {
  description = "List of availability zone of private subnets"
  value       = local.workspace["private_azs"]
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = local.workspace["private_subnet_ids"]
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = local.workspace["private_route_table_ids"]
}

output "glue_connection_sg_id" {
  description = "The ID of the glue connection security group"
  value       = local.workspace["glue_connection_sg_id"]
}

output "smb_lambda_sg_id" {
  description = "The ID of the SMB lambda security group"
  value       = local.workspace["smb_lambda_sg_id"]
}
