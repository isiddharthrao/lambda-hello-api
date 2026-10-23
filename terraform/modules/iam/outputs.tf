output "common_policy_arn" {
  description = "ARN of common-iam-policy (ssm:*)."
  value       = aws_iam_policy.common.arn
}

output "s3_policy_arn" {
  description = "ARN of s3-access-policy (s3:*)."
  value       = aws_iam_policy.s3.arn
}

output "sqs_policy_arn" {
  description = "ARN of sqs-access-policy (sqs:*)."
  value       = aws_iam_policy.sqs.arn
}
