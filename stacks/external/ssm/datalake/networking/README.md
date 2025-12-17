<!-- BEGIN_TF_DOCS -->



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
      vpc_id                  = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).vpc_id, null)
      public_azs              = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).public_azs, null)
      public_subnet_ids       = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).public_subnet_ids, null)
      public_route_table_ids  = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).public_route_table_ids, null)
      private_azs             = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).private_azs, null)
      private_subnet_ids      = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).private_subnet_ids, null)
      private_route_table_ids = try(jsondecode(data.aws_ssm_parameter.network.insecure_value).private_route_table_ids, null)

      glue_connection_sg_id = try(jsondecode(data.aws_ssm_parameter.networking.insecure_value).glue_connection_sg_id, null)
      smb_lambda_sg_id      = try(jsondecode(data.aws_ssm_parameter.networking.insecure_value).smb_lambda_sg_id, null)
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.networking](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

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
| <a name="output_glue_connection_sg_id"></a> [glue\_connection\_sg\_id](#output\_glue\_connection\_sg\_id) | The ID of the glue connection security group |
| <a name="output_private_azs"></a> [private\_azs](#output\_private\_azs) | List of availability zone of private subnets |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of IDs of private route tables |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | List of IDs of private subnets |
| <a name="output_public_azs"></a> [public\_azs](#output\_public\_azs) | List of availability zone of public subnets |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | List of IDs of public toute tables |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | List of IDs of public subnets |
| <a name="output_smb_lambda_sg_id"></a> [smb\_lambda\_sg\_id](#output\_smb\_lambda\_sg\_id) | The ID of the SMB lambda security group |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |

<!-- END_TF_DOCS -->