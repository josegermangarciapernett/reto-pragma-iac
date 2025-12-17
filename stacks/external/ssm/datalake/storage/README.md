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
      assets_bucket_id = try(jsondecode(data.aws_ssm_parameter.storage.insecure_value).assets_bucket_id, null)
      bronce_bucket_id = try(jsondecode(data.aws_ssm_parameter.storage.insecure_value).bronce_bucket_id, null)
      silver_bucket_id = try(jsondecode(data.aws_ssm_parameter.storage.insecure_value).silver_bucket_id, null)
      gold_bucket_id   = try(jsondecode(data.aws_ssm_parameter.storage.insecure_value).gold_bucket_id, null)
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
| [aws_ssm_parameter.storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

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
| <a name="output_assets_bucket_id"></a> [assets\_bucket\_id](#output\_assets\_bucket\_id) | The name of the bucket. |
| <a name="output_bronce_bucket_id"></a> [bronce\_bucket\_id](#output\_bronce\_bucket\_id) | The name of the bucket. |
| <a name="output_gold_bucket_id"></a> [gold\_bucket\_id](#output\_gold\_bucket\_id) | The name of the bucket. |
| <a name="output_silver_bucket_id"></a> [silver\_bucket\_id](#output\_silver\_bucket\_id) | The name of the bucket. |

<!-- END_TF_DOCS -->