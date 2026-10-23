variable "name" {
  description = "Name prefix for the HTTP API."
  type        = string
}

variable "routes" {
  description = "HTTP API routes. Each entry invokes one Lambda function."
  type = map(object({
    route_key            = string
    lambda_function_name = string
    lambda_invoke_arn    = string
  }))
}
