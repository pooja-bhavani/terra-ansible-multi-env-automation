# ============================================================
# Root module — workspace-driven multi-environment infra
# Usage:
#   terraform workspace new dev   && terraform apply
#   terraform workspace new prod  && terraform apply
# ============================================================

  locals {
    config = {
      dev = {
        ec2 = 2
        s3  = 1
        ddb = 1
      }
      stag = {
        ec2 = 3
        s3  = 1
        ddb = 1
      }
      prod = {
        ec2 = 4
        s3  = 2
        ddb = 2
      }
    }

    current = lookup(local.config, terraform.workspace, local.config["dev"])
  }

  data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = [var.ami_owner]

    filter {
      name   = "name"
      values = [var.ami_name_filter]
    }
  }

  resource "tls_private_key" "ssh" {
    algorithm = "RSA"
    rsa_bits  = 4096
  }

  resource "aws_key_pair" "this" {
    key_name   = "${terraform.workspace}-key"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  resource "aws_secretsmanager_secret" "ssh_key" {
    name                    = "${terraform.workspace}/ec2/ssh-private-key"
    recovery_window_in_days = 0
  }

  resource "aws_secretsmanager_secret_version" "ssh_key" {
    secret_id     = aws_secretsmanager_secret.ssh_key.id
    secret_string = tls_private_key.ssh.private_key_pem
  }

  module "ec2" {
    source               = "./modules/ec2"
    instance_count       = local.current.ec2
    instance_type        = var.instance_type
    ami_id               = data.aws_ami.ubuntu.id
    key_name             = aws_key_pair.this.key_name
    iam_instance_profile = aws_iam_instance_profile.ec2.name
    env                  = terraform.workspace
  }

  module "s3" {
    source       = "./modules/s3"
    bucket_count = local.current.s3
    env          = terraform.workspace
  }

  module "dynamodb" {
    source      = "./modules/dynamodb"
    table_count = local.current.ddb
    env         = terraform.workspace
  }
