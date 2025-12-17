/*
* # Module for Transversal resource Group
* 
* Terraform stack to provision a resource group for all project resources layer using the following Terraform modules and resources:
* 
* ## Modules & Resources
* ### Module - net_resources
* **Source Module info:**
* - **Version** : "5.0.0"
* - **Link**    : [terraform-aws-resource-groups](../../../modules/terraform-aws-resource-groups)
* 
*/

module "net_resources" {
  source = "../../modules/terraform-aws-resource-groups"

  create_resource_group = local.workspace["create_resource_group"]
  enable_app_insights   = local.workspace["enable_app_insights"]
  description           = local.workspace["description"]
  resource_group_name   = local.workspace["resource_group_name"]
  resource_tags_filters = local.workspace["resource_tags_filters"]

  tags = local.workspace["tags"]
}
