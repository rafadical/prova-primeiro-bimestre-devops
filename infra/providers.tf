# ==================================================
# Provider AWS + backend S3 (remote state)
# O bucket e a tabela são criados ANTES por infra/backend/.
# ==================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state: S3 (versionado e encriptado) + DynamoDB (locking)
  # Blocos backend não aceitam variáveis: o nome do bucket vem do
  # output s3_bucket_name de infra/backend (preenchido na Etapa 10).
  backend "s3" {
    bucket         = "technova-6322006-tfstate-a6e6b7ad"
    key            = "prova/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "technova-6322006-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  # Tags aplicadas automaticamente a todos os recursos
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner_ra
    }
  }
}
