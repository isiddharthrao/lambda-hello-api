output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "lambda_function_names" {
  description = "Name of each hello-world Lambda function."
  value       = { for key, fn in module.lambda : key => fn.function_name }
}

output "lambda_function_arns" {
  description = "ARN of each hello-world Lambda function."
  value       = { for key, fn in module.lambda : key => fn.function_arn }
}

output "iam_policy_arns" {
  description = "Customer-managed policies attached to the function roles."
  value = {
    common = module.iam.common_policy_arn
    s3     = module.iam.s3_policy_arn
    sqs    = module.iam.sqs_policy_arn
  }
}

output "api_endpoint" {
  description = "Base URL of the HTTP API."
  value       = module.api_gateway.api_endpoint
}

output "invoke_urls" {
  description = "URL that invokes each function. GET / is lambda_1, /lambda-2 is lambda_2, /lambda-3 is lambda_3."
  value = {
    for key, fn in local.functions :
    key => "${module.api_gateway.api_endpoint}${replace(fn.route_key, "/^[A-Z]+ /", "/")}"
  }
}
