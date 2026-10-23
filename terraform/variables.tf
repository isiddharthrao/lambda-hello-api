variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Project name, used as a prefix for resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (NAT gateway)."
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet (Lambda functions)."
  type        = string
  default     = "10.0.1.0/24"
}

variable "lambda_runtime" {
  description = "Lambda runtime identifier."
  type        = string
  default     = "python3.14"
}

variable "lambda_handler" {
  description = "Lambda handler in module.function form."
  type        = string
  default     = "handler.lambda_handler"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Lambda memory in MB."
  type        = number
  default     = 128
}

