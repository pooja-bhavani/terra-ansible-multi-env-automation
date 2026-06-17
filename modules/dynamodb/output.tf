output "table_names" {
  value = aws_dynamodb_table.this[*].name
}