 resource "aws_iam_role" "ec2" {
    name = "${terraform.workspace}-ec2-role"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }]
    })
  }

  resource "aws_iam_role_policy" "ec2_secrets" {
    name = "${terraform.workspace}-ec2-secrets"
    role = aws_iam_role.ec2.id

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = aws_secretsmanager_secret.ssh_key.arn
      }]
    })
  }

  resource "aws_iam_instance_profile" "ec2" {
    name = "${terraform.workspace}-ec2-profile"
    role = aws_iam_role.ec2.name
  }
