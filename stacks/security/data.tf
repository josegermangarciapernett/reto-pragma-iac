data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "key_policy_infra" {
  #checkov:skip=CKV_AWS_109:This policy meets quality standards
  #checkov:skip=CKV_AWS_111:This policy meets quality standards
  #checkov:skip=CKV_AWS_356:This policy meets quality standards
  statement {
    sid    = "Allow access for generic principals to view kms"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "logs.amazonaws.com",
        "secretsmanager.amazonaws.com"
      ]
    }
    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow access through cloudwatch for all principals in the account that are authorized to use kms"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:CreateGrant",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    condition {
      test = "ArnEquals"
      values = [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc-flow-log/*"
      ]
      variable = "kms:EncryptionContext:aws:logs:arn"
    }
  }
  statement {
    sid    = "Allow access through for all principals in the account that are authorized to use kms"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:CreateGrant",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "kms:CallerAccount"
    }
    condition {
      test = "StringEquals"
      values = [
        "secretsmanager.${data.aws_region.current.name}.amazonaws.com",
      ]
      variable = "kms:ViaService"
    }
  }
}

data "aws_iam_policy_document" "key_policy_storage" {
  #checkov:skip=CKV_AWS_109:This policy meets quality standards
  #checkov:skip=CKV_AWS_111:This policy meets quality standards
  #checkov:skip=CKV_AWS_356:This policy meets quality standards
  statement {
    sid    = "Allow access for storage principals to view kms"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "s3.amazonaws.com",
        "rds.amazonaws.com",
        "dynamodb.amazonaws.com"
      ]
    }
    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow access to KMS key from storage principals in the account for use"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:CreateGrant",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "kms:CallerAccount"
    }
    condition {
      test = "StringEquals"
      values = [
        "ec2.${data.aws_region.current.name}.amazonaws.com",
        "s3.${data.aws_region.current.name}.amazonaws.com",
        "rds.${data.aws_region.current.name}.amazonaws.com",
        "dynamodb.${data.aws_region.current.name}.amazonaws.com",
      ]
      variable = "kms:ViaService"
    }
  }
}
