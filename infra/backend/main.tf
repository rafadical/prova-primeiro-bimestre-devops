# ==================================================
# Backend do Remote State (S3 + DynamoDB)
# Projeto separado: deve ser aplicado ANTES do projeto
# principal (infra/), que usa este bucket no backend "s3".
# O state deste projeto fica local (não versionado).
# ==================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
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
      Purpose     = "Terraform Remote State"
    }
  }
}
