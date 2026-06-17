variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_owner" {
  description = "AMI owner ID (Canonical = Ubuntu)"
  type        = string
  default     = "099720109477"
}

variable "ami_name_filter" {
  description = "AMI name filter for the dynamic lookup"
  type        = string
  default     = "ubuntu/images/hvm-ssd/*amd64*"
}