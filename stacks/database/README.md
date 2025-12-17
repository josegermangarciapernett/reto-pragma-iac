<!-- BEGIN_TF_DOCS -->

# Module for Databases deployment

Terraform stack to provision compute elements using the next Terraform modules and resources:

## Modules & Resources Info
- [terraform-aws-modules/dynamodb-table/aws](https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table):v4.3.0

## Code Dependencies Graph
<center>

   ![Graph](./graph.svg)

  ##### **Dependency Graph**

</center>

---

## Example parameter options for each environment

```hcl

 locals {
  env = {
    default = {
      #############################################################################
      # Common Parameters
      #############################################################################
      tags = {
        Environment = terraform.workspace
        Protected   = false
        Layer       = "Database"
      }
      #############################################################################
      # dynamodb Module
      #############################################################################
      table_use_case_emails = {
        name      = "${var.prefix}-${terraform.workspace}-use-case-emails"
        hash_key  = "useCaseId"
        range_key = "emailType"
        attributes = [
          { name = "useCaseId", type = "S" },
          { name = "emailType", type = "S" },
        ]
      }
      table_use_case_queries = {
        name      = "${var.prefix}-${terraform.workspace}-use-case-queries"
        hash_key  = "useCaseId"
        range_key = "queryName"
        attributes = [
          { name = "useCaseId", type = "S" },
          { name = "queryName", type = "S" },
        ]
      }
      table_use_case_certification = {
        name      = "${var.prefix}-${terraform.workspace}-use-case-certification"
        hash_key  = "useCaseId"
        range_key = "certCode"
        attributes = [
          { name = "useCaseId", type = "S" },
          { name = "certCode", type = "S" },
        ]
      }
      table_use_case_approvers = {
        name      = "${var.prefix}-${terraform.workspace}-use-case-approvers"
        hash_key  = "useCaseId"
        range_key = null
        attributes = [
          { name = "useCaseId", type = "S" }
        ]
      }
      used_tables = []
    }
    dev = {
      used_tables = [
        "table_use_case_emails",
        "table_use_case_queries",
        "table_use_case_certification",
        "table_use_case_approvers",
      ]
    }
    qa = {
      used_tables = [
        "table_use_case_emails",
        "table_use_case_queries",
        "table_use_case_certification",
        "table_use_case_approvers",
      ]
    }
    prd = {
      used_tables = []
    }
  }
  # Set workspace parameters for the associated environment
  environment_vars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace        = merge(local.env["default"], local.env[local.environment_vars])
}

```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.92.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | terraform-aws-modules/dynamodb-table/aws | 4.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_infra_key_arn"></a> [infra\_key\_arn](#input\_infra\_key\_arn) | The ARN for the KMS encryption key | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->