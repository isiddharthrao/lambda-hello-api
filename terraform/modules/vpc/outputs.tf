output "vpc_id" {
  description = "VPC identifier."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "Public subnet identifier (hosts the NAT gateway)."
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet identifier (hosts the Lambda functions)."
  value       = aws_subnet.private.id
}

output "nat_gateway_id" {
  description = "NAT gateway identifier."
  value       = aws_nat_gateway.this.id
}

output "lambda_security_group_id" {
  description = "Security group attached to the Lambda functions."
  value       = aws_security_group.lambda.id
}
