locals {
  create_rest_api_policy = var.create && var.create_rest_api_policy && var.policy_statements != null && var.policy_statements != {}
  create_log_group       = var.create && var.logging_level != "OFF"
  log_group_arn          = local.create_log_group ? try(aws_cloudwatch_log_group.this[0].arn, null) : null
  vpc_link_enabled       = var.create && length(var.private_link_target_arns) > 0
}

resource "aws_api_gateway_rest_api" "this" {
  count = var.create ? 1 : 0

  name = var.name
  body = jsonencode(var.openapi_config)
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )

  endpoint_configuration {
    types            = [var.endpoint_type]
    vpc_endpoint_ids = var.vpc_endpoint_ids
  }
}

resource "aws_api_gateway_rest_api_policy" "this" {
  count       = local.create_rest_api_policy ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id

  policy = data.aws_iam_policy_document.api_policy[0].json
}

resource "aws_api_gateway_deployment" "this" {
  count       = var.create ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this[0].body))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_rest_api_policy.this]
}

resource "aws_api_gateway_stage" "this" {
  count                = var.create ? 1 : 0
  deployment_id        = aws_api_gateway_deployment.this[0].id
  rest_api_id          = aws_api_gateway_rest_api.this[0].id
  stage_name           = var.stage_name
  xray_tracing_enabled = var.xray_tracing_enabled
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )

  variables = {
    vpc_link_id = local.vpc_link_enabled ? aws_api_gateway_vpc_link.this[0].id : null
  }

  dynamic "access_log_settings" {
    for_each = local.create_log_group ? [1] : []

    content {
      destination_arn = local.log_group_arn
      format          = replace(var.access_log_format, "\n", "")
    }
  }
}

# Set the logging, metrics and tracing levels for all methods
resource "aws_api_gateway_method_settings" "all" {
  count       = var.create ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this[0].id
  stage_name  = aws_api_gateway_stage.this[0].stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = var.metrics_enabled
    logging_level   = var.logging_level
  }
}

# Optionally create a VPC Link to allow the API Gateway to communicate with private resources (e.g. ALB)
resource "aws_api_gateway_vpc_link" "this" {
  count       = local.vpc_link_enabled ? 1 : 0
  name        = var.name
  description = "VPC Link for ${var.name}"
  target_arns = var.private_link_target_arns
}

################################################################################
# Log group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = local.create_log_group ? 1 : 0

  name              = "/aws/apigateway/${var.name}"
  retention_in_days = var.log_group_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = merge(var.tags, var.log_group_tags)
}

################################################################################
# Integrations
################################################################################

resource "aws_lambda_permission" "apigtw_lambda" {
  for_each = { for k, v in var.lambda_integrations : k => v if var.create && length(var.lambda_integrations) > 0 }

  function_name      = each.value.name
  qualifier          = each.value.version
  event_source_token = each.value.event_source_token
  statement_id       = each.value.statement_id

  action     = "lambda:InvokeFunction"
  principal  = "apigateway.amazonaws.com"
  source_arn = format("%s%s", aws_api_gateway_rest_api.this[0].execution_arn, each.value.api_resource == null ? "/*/*" : each.value.api_resource)
}
