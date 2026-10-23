variable "aws_region" {
  description = "Region for the state bucket. Must match aws_region in terraform/environments/prod.tfvars."
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Must match `project` in terraform/environments/prod.tfvars; IAM role permissions are scoped to this prefix."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the roles, as <owner>/<repo>."
  type        = string
}

variable "github_environment" {
  description = "GitHub environment used by the apply job in .github/workflows/terraform.yml."
  type        = string
  default     = "production"
}

variable "state_bucket_name" {
  description = "Globally unique name for the Terraform state bucket."
  type        = string
}

variable "create_oidc_provider" {
  description = "Set false if the account already has the token.actions.githubusercontent.com OIDC provider."
  type        = bool
  default     = true
}

variable "stack_policy_names" {
  description = "Customer-managed IAM policies created by terraform/modules/iam. The apply role may manage only these."
  type        = list(string)
  default     = ["common-iam-policy", "s3-access-policy", "sqs-access-policy"]
}
