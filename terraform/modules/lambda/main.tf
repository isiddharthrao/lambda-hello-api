data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${var.build_dir}/${var.name}-lambda.zip"
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Grants ENI management for VPC attachment plus CloudWatch Logs write.
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "extra" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}-fn"
  retention_in_days = 14
}

resource "aws_lambda_function" "this" {
  function_name    = "${var.name}-fn"
  description      = "Returns hello world when invoked by API Gateway."
  role             = aws_iam_role.this.arn
  runtime          = var.runtime
  handler          = var.handler
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  timeout          = var.timeout
  memory_size      = var.memory_size

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.vpc_access,
    aws_iam_role_policy_attachment.xray,
    aws_iam_role_policy_attachment.extra,
    aws_cloudwatch_log_group.this,
  ]
}
