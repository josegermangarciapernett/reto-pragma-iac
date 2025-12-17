# variable "infra_key_arn" {
#   description = "The ARN for the KMS encryption key"
#   type        = string
# }

# variable "private_subnet_ids" {
#   type        = list(string)
#   description = "A list of private subnet IDs"
#   validation {
#     condition = alltrue([
#       for s in var.private_subnet_ids : can(regex("^subnet-", s))
#     ])
#     error_message = "Almost one subnet id doesn't meet the requirement id format \"^subnet-\""
#   }
# }

# variable "smb_lambda_sg_id" {
#   description = "The ID of the smb lambda security group"
#   type        = string
#   validation {
#     condition     = can(regex("^sg-", var.smb_lambda_sg_id))
#     error_message = "The security group id must be a valid id starting with \"^sg-\""
#   }
# }

# variable "assets_bucket_id" {
#   description = "ID of the bucket where the assets are stored"
#   type        = string
# }

# variable "langding_bucket_id" {
#   description = "ID of the bucket where the langding are stored"
#   type        = string
# }

# variable "create_smb_lambda" {
#   description = "Enabled create lambda function"
#   type        = bool
#   default     = true
# }

# variable "create_cont_lambda" {
#   description = "Enabled create lambda function"
#   type        = bool
#   default     = true
# }
