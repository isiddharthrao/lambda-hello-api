data "aws_iam_policy_document" "common" {
  statement {
    sid       = "SsmAccess"
    actions   = ["ssm:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid       = "S3Access"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sqs" {
  statement {
    sid       = "SqsAccess"
    actions   = ["sqs:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "common" {
  name        = "common-iam-policy"
  description = "SSM access attached to every Lambda function."
  policy      = data.aws_iam_policy_document.common.json
}

resource "aws_iam_policy" "s3" {
  name        = "s3-access-policy"
  description = "S3 access attached to lambda_2 only."
  policy      = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_policy" "sqs" {
  name        = "sqs-access-policy"
  description = "SQS access attached to lambda_3 only."
  policy      = data.aws_iam_policy_document.sqs.json
}
