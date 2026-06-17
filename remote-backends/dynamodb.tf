resource "aws_dynamodb_table" "locks" {
  name         = "tfstate-multienv-statelock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"          # must be exactly "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}