output "state_bucket" {
  description = "Set as the GitHub variable TF_STATE_BUCKET."
  value       = aws_s3_bucket.state.id
}

output "plan_role_arn" {
  description = "Set as the GitHub variable AWS_PLAN_ROLE_ARN."
  value       = aws_iam_role.plan.arn
}

output "apply_role_arn" {
  description = "Set as the GitHub variable AWS_APPLY_ROLE_ARN."
  value       = aws_iam_role.apply.arn
}

output "aws_region" {
  description = "Set as the GitHub variable AWS_REGION."
  value       = var.aws_region
}
