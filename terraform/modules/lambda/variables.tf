variable "name" {
  description = "Name prefix for the function, role and log group."
  type        = string
}

variable "source_dir" {
  description = "Directory containing the Lambda source code."
  type        = string
}

variable "build_dir" {
  description = "Directory where the packaged zip is written."
  type        = string
}

variable "runtime" {
  description = "Lambda runtime identifier."
  type        = string
  default     = "python3.14"
}

variable "handler" {
  description = "Lambda handler in module.function form."
  type        = string
  default     = "handler.lambda_handler"
}

variable "timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Lambda memory in MB."
  type        = number
  default     = 128
}

variable "subnet_ids" {
  description = "Private subnet IDs the function attaches to."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for the function's network interfaces."
  type        = list(string)
}

variable "policy_arns" {
  description = "Customer-managed IAM policy ARNs to attach to this function's execution role."
  type        = list(string)
  default     = []
}
