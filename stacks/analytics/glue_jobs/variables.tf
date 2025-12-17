variable "storage_kms_key_arn" {
  description = "The ARN for the KMS encryption key"
  type        = string
}

variable "jdbc_secret_ids" {
  description = "Map with the IDs of the database credential secrets"
  type        = map(string)
}

variable "private_azs" {
  type        = list(string)
  description = "List of availability zone of private subnets"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "A list of private subnet IDs"
  validation {
    condition = alltrue([
      for s in var.private_subnet_ids : can(regex("^subnet-", s))
    ])
    error_message = "Almost one subnet id doesn't meet the requirement id format \"^subnet-\""
  }
}

variable "glue_connection_sg_id" {
  description = "The ID of the glue connection security group"
  type        = string
  validation {
    condition     = can(regex("^sg-", var.glue_connection_sg_id))
    error_message = "The security group id must be a valid id starting with \"^sg-\""
  }
}

variable "glue_connection_names" {
  description = "Map with the names of the Glue Connections"
  type        = map(string)
}

variable "assets_bucket_id" {
  description = "ID of the bucket where the assets are stored"
  type        = string
}

variable "bronce_bucket_id" {
  description = "ID of the bucket where the data bronce are stored"
  type        = string
}

variable "silver_bucket_id" {
  description = "ID of the bucket where the data silver are stored"
  type        = string
}

variable "gold_bucket_id" {
  description = "ID of the bucket where the data gold are stored"
  type        = string
}
