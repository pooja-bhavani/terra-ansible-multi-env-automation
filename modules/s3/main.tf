resource "aws_s3_bucket" "this" {
  count         = var.bucket_count
  bucket_prefix = "${var.env}-multienv-"   # AWS appends a unique suffix → no name collisions

  tags = {
    Name        = "${var.env}-bucket-${count.index}"
    Environment = var.env
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.bucket_count
  bucket = aws_s3_bucket.this[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.bucket_count
  bucket = aws_s3_bucket.this[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}