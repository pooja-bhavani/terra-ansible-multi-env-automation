output "environment" {
  value = terraform.workspace
}

output "ec2_public_ips" {
  value = module.ec2.public_ips
}

output "s3_bucket_names" {
  value = module.s3.bucket_names
}

output "dynamodb_table_names" {
  value = module.dynamodb.table_names
}

output "ssh_key_secret_name" {
  description = "Secrets Manager secret holding the SSH private key"
  value       = aws_secretsmanager_secret.ssh_key.name
}