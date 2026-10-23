terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.6"
    }
  }

  # Bucket, key, region and use_lockfile are supplied at `terraform init` time
  # via -backend-config (see .github/workflows/terraform.yml).
  backend "s3" {}
}
