variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (NAT gateway)."
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet (Lambda functions)."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for both subnets."
  type        = string
}
