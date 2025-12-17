# General variables

# tflint-ignore: terraform_unused_declarations
variable "profile" {
  description = "Variable for credentials management."
  type        = map(map(string))
  default = {
    default = {
      profile = "sh-deploy-account-profile"
      region  = "us-east-2"
    }
    dev = {
      profile = "sh-deploy_dev_account"
      region  = "us-east-1"
    }
  }
}

# tflint-ignore: terraform_unused_declarations
variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "example"
}

# tflint-ignore: terraform_unused_declarations
variable "project" {
  description = "Project name"
  type        = string
  default     = "project_name"
}

# tflint-ignore: terraform_unused_declarations
variable "required_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Project   = "project_name"
    Owner     = "owner_name"
    ManagedBy = "Terraform-Terragrunt"
  }
}
