terraform {
    required_version = ">= 1.5.0"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 6.0"
      }
      tls = {
        source  = "hashicorp/tls"
        version = "~> 4.0"
      }
    }

    backend "s3" {
      bucket         = "tfstate-multienv-2026"
      key            = "infra/terraform.tfstate"
      region         = "ap-south-1"
      dynamodb_table = "tfstate-multienv-statelock"
      encrypt        = true
    }
  }
