variable "bucket_count" {
  description = "How many S3 buckets to create"
  type        = number
}

variable "env" {
  description = "Environment name (the workspace)"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}