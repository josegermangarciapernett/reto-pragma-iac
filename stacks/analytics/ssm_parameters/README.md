<!-- BEGIN_TF_DOCS -->

# Stack for deploying Analytics SSM Parameter Store resources
Below is information on the modules and resources
## Modules info
- [terraform-aws-modules/ssm-parameter/aws](https://github.com/terraform-aws-modules/terraform-aws-ssm-parameter): Version 1.1.0

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
      enabled_parameters = false
      tags = {
        Environment = terraform.workspace
        Layer       = "Compute"
      }
      #############################################################################
      # ssm_paramenters Module
      #############################################################################
      parameters = {
        deslizamiento = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/niif/deslizamiento"
          description = "Parameters store to store data parameters"
        }
        gastos = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/niif/gastos"
          description = "Parameters store to store data parameters"
        }
        tasa_fac_seg = {
          create      = true
          name        = "/${var.prefix}/${terraform.workspace}/niif/tasa_fac_seg"
          description = "Parameters store to store data parameters"
        }
      }
    }
    dev = {

    }
    qa = {

    }
    prd = {

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.97.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ssm_parameters"></a> [ssm\_parameters](#module\_ssm\_parameters) | terraform-aws-modules/ssm-parameter/aws | 1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | Variable for AWS Access Key | `string` | `null` | no |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | Variable for AWS Secret Key | `string` | `null` | no |
| <a name="input_aws_token"></a> [aws\_token](#input\_aws\_token) | Variable for AWS Token | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for naming resources | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | Variable for credentials management. | `map(map(string))` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | A map of tags to add to all resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssm_parameters"></a> [ssm\_parameters](#output\_ssm\_parameters) | Map with the parameter store ids |

<!-- END_TF_DOCS -->