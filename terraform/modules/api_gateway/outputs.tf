output "api_id" {
  description = "HTTP API identifier."
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "Default endpoint of the HTTP API."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "invoke_url" {
  description = "URL of the route that invokes Lambda. $default stage has no path prefix."
  value       = aws_apigatewayv2_api.this.api_endpoint
}
