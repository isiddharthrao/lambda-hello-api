# lambda-hello-api

Three Python 3.14 Lambda functions behind a public API Gateway HTTP API, deployed with Terraform from GitHub Actions. Each function returns `hello world`.

```text
Internet ──► API Gateway (HTTP API, public)
                │  GET /          ─► lambda_1  (common-iam-policy)
                │  GET /lambda-2  ─► lambda_2  (common-iam-policy + s3-access-policy)
                │  GET /lambda-3  ─► lambda_3  (common-iam-policy + sqs-access-policy)
                ▼
VPC 10.0.0.0/16
├── public subnet  10.0.0.0/24  ── NAT gateway, internet gateway
└── private subnet 10.0.1.0/24  ── Lambda functions (outbound HTTPS via NAT only)
```

API Gateway is an AWS-managed public endpoint, so it isn't placed in a subnet. It invokes the functions through the Lambda service.

## Repository layout

| Path | Purpose |
|---|---|
| `bootstrap/` | One-time setup run locally: state bucket, GitHub OIDC provider, plan and apply roles |
| `terraform/` | The application stack (VPC, IAM policies, Lambda, API Gateway) |
| `terraform/environments/prod.tfvars` | Values for the production deployment |
| `terraform/lambda_src/handler.py` | Function code shared by all three functions |
| `.github/workflows/terraform.yml` | Plan on pull request, apply after an approved merge |
| `.github/scripts/require_approved_merge.py` | Blocks deployment unless the merged pull request was approved |

## Prerequisites

- An AWS account and local credentials with administrator access (used once, for the bootstrap)
- Terraform 1.10 or later
- A GitHub repository for this code, where you can change settings

## Step 1: Bootstrap AWS (run once, locally)

The bootstrap creates what the pipeline needs before it can run: an encrypted S3 bucket for Terraform state, the GitHub OIDC identity provider, a read-only **plan** role and an **apply** role.

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region        = "ap-south-1"
project           = "hello"                          # must match project in terraform/environments/prod.tfvars
github_repository = "your-org/lambda-hello-api"      # <owner>/<repo>
state_bucket_name = "hello-terraform-state-<account-id>"  # globally unique
# create_oidc_provider = false                      # uncomment if the account already has the GitHub OIDC provider
```

Then apply it:

```bash
terraform init
terraform apply
terraform output
```

Keep the four outputs for Step 3. The bootstrap stores its state in `bootstrap/terraform.tfstate` on your machine, which git ignores. Back that file up, because Terraform can't manage these resources without it.

## Step 2: Push the code to GitHub

From the repository root:

```bash
git init
git add .
git commit -m "Initial Lambda, API Gateway and pipeline"
git branch -M main
git remote add origin git@github.com:your-org/lambda-hello-api.git
git push -u origin main
```

Commit `terraform/.terraform.lock.hcl` so CI uses the same provider versions. This first push to `main` doesn't deploy anything, because deployment only follows an approved pull request.

## Step 3: Configure the GitHub repository

**Repository variables** (Settings → Secrets and variables → Actions → Variables), filled from the bootstrap outputs:

| Variable | Bootstrap output |
|---|---|
| `TF_STATE_BUCKET` | `state_bucket` |
| `AWS_PLAN_ROLE_ARN` | `plan_role_arn` |
| `AWS_APPLY_ROLE_ARN` | `apply_role_arn` |
| `AWS_REGION` | `aws_region` |

No AWS access keys are stored in GitHub. The workflow signs in to AWS through OIDC.

**Environment** (Settings → Environments): create one named `production`. The apply role trusts only jobs running in this environment. Optionally add required reviewers for a second approval before each deployment.

**Branch protection** (Settings → Branches → add a rule for `main`):

- Require a pull request before merging, with at least 1 approval
- Require status checks to pass, and select **Validate & Plan**

## Step 4: Open a pull request

Make a change on a branch and open a pull request into `main`:

```bash
git checkout -b my-change
# edit files
git commit -am "Describe the change"
git push -u origin my-change
```

The **Validate & Plan** job runs with the read-only plan role. It checks formatting, validates the configuration and runs `terraform plan`. Review the plan output in the job log to see exactly what will change. Nothing is deployed at this stage.

## Step 5: Approve and merge to deploy

Once a reviewer approves the pull request and it's merged, the workflow runs on `main`:

1. **Require approved merge** confirms the commit came from a merged pull request that has an approval and no outstanding change requests. Direct pushes to `main` stop here and don't deploy.
2. **Apply** assumes the apply role in the `production` environment, plans again against the merged code and runs `terraform apply`.

The first deployment takes a few minutes, mostly for the NAT gateway.

## Step 6: Call the API

The **Apply** job log ends with the Terraform outputs. `invoke_urls` lists one URL per function:

```bash
curl https://<api-id>.execute-api.ap-south-1.amazonaws.com/
curl https://<api-id>.execute-api.ap-south-1.amazonaws.com/lambda-2
curl https://<api-id>.execute-api.ap-south-1.amazonaws.com/lambda-3
```

Each returns `hello world`. Function logs are in CloudWatch under `/aws/lambda/hello-prod-lambda-<n>-fn`, and API access logs under `/aws/apigateway/hello-prod-api`.

## Validating changes locally

Before opening a pull request, you can run the same checks as CI without touching AWS:

```bash
terraform fmt -check -recursive
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
python3 -m py_compile terraform/lambda_src/handler.py
```

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `Not authorized to perform sts:AssumeRoleWithWebIdentity` | `github_repository` in the bootstrap doesn't match the repo, or the apply job isn't in the `production` environment |
| Apply fails creating `common-iam-policy` (or the S3/SQS policy) with `EntityAlreadyExists` | A policy with that name already exists in the account. IAM policy names are account-wide |
| Apply fails with `AccessDenied` on `iam:CreateRole` | `project` in `prod.tfvars` differs from the bootstrap `project`, so role names fall outside the apply role's permissions |
| Merge didn't trigger a deployment | The pull request had no approval, had changes requested, or the change was pushed directly to `main` |
| Plan fails with `Error acquiring the state lock` | Another run holds the lock. Wait for it to finish |

## Cost and limits

- The NAT gateway costs about $32 a month plus data processing charges. Lambda, API Gateway and CloudWatch are pay-per-use and negligible at low traffic.
- The stack uses a single availability zone, so an outage in that zone takes the functions down.
- `common-iam-policy`, `s3-access-policy` and `sqs-access-policy` grant `ssm:*`, `s3:*` and `sqs:*` on all resources. Narrow them to specific parameters, buckets and queues once those exist.

## Tearing down

Run `terraform destroy` locally against the same state, using credentials with permissions equivalent to the apply role:

```bash
cd terraform
terraform init \
  -backend-config="bucket=<state bucket>" \
  -backend-config="key=lambda-hello-api/prod/terraform.tfstate" \
  -backend-config="region=ap-south-1" \
  -backend-config="use_lockfile=true" \
  -backend-config="encrypt=true"
terraform destroy -var-file=environments/prod.tfvars
```

Lambda network interfaces can take up to 20 minutes to release, so the VPC deletion may be slow. The bootstrap state bucket is protected from deletion on purpose.
