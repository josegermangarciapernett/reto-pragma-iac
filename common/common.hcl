# Load variables in locals
locals {
  # Default values for variables
  prefix       = "pragma"
  project      = "ecommerce"

  # Backend Configuration
  backend_profile       = "sh-alfa-devops"
  backend_region        = "us-east-2"
  backend_bucket_name   = "jfc-pragma-terraform-storage"
  backend_key           = "terraform.tfstate"
  backend_dynamodb_lock = "jfc-pragma-terraform-locks"
  backend_encrypt       = true
  # Format cloud prefix/project
  project_folder = "${local.prefix}/${local.project}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "profile" {
  description = "Variable for credentials management."
  type        = map(map(string))
}

variable "aws_access_key" {
  description = "Variable for AWS Access Key"
  type        = string
  default     = null
}

variable "aws_secret_key" {
  description = "Variable for AWS Secret Key"
  type        = string
  default     = null
}

variable "aws_token" {
  description = "Variable for AWS Token"
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "required_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

provider "aws" {
  region     = var.profile[terraform.workspace]["region"]
  profile    = var.aws_access_key == null || var.aws_secret_key == null ? var.profile[terraform.workspace]["profile"] : null
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_token

  default_tags {
    tags = var.required_tags
  }
}
EOF
}
