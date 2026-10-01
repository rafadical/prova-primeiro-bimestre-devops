# ==================================================
# Bucket S3 do remote state
#
# Por que o bucket NÃO é um "resource aws_s3_bucket":
# o AWS Academy Learner Lab possui uma SCP que nega
# s3:GetBucketObjectLockConfiguration, chamada que o provider
# AWS executa ao ler qualquer aws_s3_bucket (erro AccessDenied).
# Por isso o bucket é criado/removido via AWS CLI e o Terraform
# gerencia as configurações exigidas: versionamento,
# encriptação e bloqueio de acesso público.
# (O professor admite criar o backend manualmente:
#  aula-06/laboratorio-parte2.md, Passo 5.1.)
#
# Criação (do zero), executada na pasta infra/backend:
#   terraform apply -target=random_id.bucket_suffix
#   B=$(terraform output -raw s3_bucket_name)
#   aws s3api create-bucket --bucket "$B" --region us-east-1
#   aws s3api put-bucket-tagging --bucket "$B" --tagging \
#     'TagSet=[{Key=Project,Value=technova},{Key=Environment,Value=dev},{Key=ManagedBy,Value=Terraform},{Key=Owner,Value=6322006},{Key=Purpose,Value="Terraform Remote State"}]'
#   terraform apply
#
# Remoção (após o terraform destroy do projeto principal infra/):
#   B=$(terraform output -raw s3_bucket_name)
#   terraform destroy
#   aws s3 rb "s3://$B" --force   # (versões do state: ver Etapa 12)
# ==================================================

# Sufixo aleatório: nomes de bucket S3 são globalmente únicos
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.project_name}-${var.owner_ra}-tfstate-${random_id.bucket_suffix.hex}"
}

# Versionamento: histórico do state (permite rollback)
resource "aws_s3_bucket_versioning" "state" {
  bucket = local.bucket_name

  versioning_configuration {
    status = "Enabled"
  }
}

# Encriptação server-side (SSE-S3 / AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = local.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueio total de acesso público ao bucket do state
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = local.bucket_name

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
