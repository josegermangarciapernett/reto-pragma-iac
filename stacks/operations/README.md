<!-- BEGIN_TF_DOCS -->

# Module for Transversal resource Group

Terraform stack to provision a resource group for all project resources layer using the following Terraform modules and resources:

## Modules & Resources
### Module - net\_resources
**Source Module info:**
- **Version** : "5.0.0"
- **Link**    : [terraform-aws-resource-groups](../../../modules/terraform-aws-resource-groups)

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
      create_resource_group = false
      enable_app_insights   = false
      description           = "Resource group for ${var.project} Resources for ${terraform.workspace}"
      resource_group_name   = "${var.project}-${terraform.workspace}"
      resource_tags_filters = {
        ResourceTypeFilters = ["AWS::AllSupported"],
        TagFilters = [
          {
            Key    = "Project",
            Values = [var.required_tags["Project"]]
          }
        ]
      }
      tags = {
        Environment = terraform.workspace
        Layer       = "Operations"
      }
    }
    dev = {
      create_resource_group = true
      enable_app_insights   = true
    }
    qa = {
      create_resource_group = true
      enable_app_insights   = true
    }
    prd = {
      create_resource_group = true
      enable_app_insights   = true
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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_net_resources"></a> [net\_resources](#module\_net\_resources) | ../../modules/terraform-aws-resource-groups | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_arn"></a> [resource\_group\_arn](#output\_resource\_group\_arn) | Resource Tag ARN |

<!-- END_TF_DOCS -->