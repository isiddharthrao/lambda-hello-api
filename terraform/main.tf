locals {
  name = "${var.project}-${var.environment}"

  # lambda_1 gets the shared SSM policy only.
  # lambda_2 also gets S3. lambda_3 also gets SQS.
  functions = {
    lambda_1 = {
      route_key   = "GET /"
      policy_arns = [module.iam.common_policy_arn]
    }
    lambda_2 = {
      route_key = "GET /lambda-2"
      policy_arns = [
        module.iam.common_policy_arn,
        module.iam.s3_policy_arn,
      ]
    }
    lambda_3 = {
      route_key = "GET /lambda-3"
      policy_arns = [
        module.iam.common_policy_arn,
        module.iam.sqs_policy_arn,
      ]
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  name                = local.name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = data.aws_availability_zones.available.names[0]
}

module "iam" {
  source = "./modules/iam"
}

module "lambda" {
  source   = "./modules/lambda"
  for_each = local.functions

  name        = "${local.name}-${replace(each.key, "_", "-")}"
  source_dir  = "${path.root}/lambda_src"
  build_dir   = "${path.root}/.build"
  runtime     = var.lambda_runtime
  handler     = var.lambda_handler
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size
  policy_arns = each.value.policy_arns

  subnet_ids         = [module.vpc.private_subnet_id]
  security_group_ids = [module.vpc.lambda_security_group_id]
}

module "api_gateway" {
  source = "./modules/api_gateway"

  name = local.name
  routes = {
    for key, fn in local.functions : key => {
      route_key            = fn.route_key
      lambda_function_name = module.lambda[key].function_name
      lambda_invoke_arn    = module.lambda[key].invoke_arn
    }
  }
}
