data "aws_iam_policy_document" "api_policy" {
  count = local.create_rest_api_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.policy_statements

    content {
      sid         = try(statement.value.sid, null)
      actions     = try(statement.value.actions, null)
      not_actions = try(statement.value.not_actions, null)
      effect      = try(statement.value.effect, null)
      resources   = [format("%s%s", try(aws_api_gateway_rest_api.this[0].execution_arn, ""), try(statement.value.resource, "/*"))]

      dynamic "principals" {
        for_each = try([statement.value.principals], [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try([statement.value.not_principals], [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, {})

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}