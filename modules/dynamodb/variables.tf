variable "table_count" {
  description = "How many DynamoDB tables to create"
  type        = number
}

variable "env" {
  description = "Environment name (the workspace)"
  type        = string
}

output "table_arns" {
  description = "ARNs of the DynamoDB tables"
  value       = aws_dynamodb_table.this[*].arn
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}