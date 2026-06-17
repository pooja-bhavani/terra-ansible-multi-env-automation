resource "aws_dynamodb_table" "this" {
  count        = var.table_count
  name         = "${var.env}-app-table-${count.index}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "${var.env}-app-table-${count.index}"
    Environment = var.env
  }
}
