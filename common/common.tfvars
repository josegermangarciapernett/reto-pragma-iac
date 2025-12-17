# Default values for deployment credentials
# Access profile in your IDE env or pipeline the IAM user to use for deployment."
profile = {
  default = {
    profile = "sh-pragma-dev"
    region  = "us-east-1"
  }
  dev = {
    profile = "sh-pragma-dev"
    region  = "us-east-1"
  }
  qa = {
    profile = "sh-pragma-qa"
    region  = "us-east-1"
  }
  prd = {
    profile = "sh-pragma-prd"
    region  = "us-east-1"
  }
}

# Project Variable
prefix  = "pragma"
project = "ecommerce"

# Project default tags
required_tags = {
  Project   = "ecommerce-jfc"
  Owner     = "ecommerce"
  ManagedBy = "Terraform-Terragrunt"
}
