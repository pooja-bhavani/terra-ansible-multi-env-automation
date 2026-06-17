output "public_ips" {
  value = aws_instance.this[*].public_ip
}

output "instance_ids" {
  value = aws_instance.this[*].id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}