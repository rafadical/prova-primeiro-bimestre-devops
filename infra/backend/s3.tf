# Sufixo aleatório: nomes de bucket S3 são globalmente únicos
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Bucket que armazena o terraform.tfstate do projeto principal
resource "aws_s3_bucket" "state" {
  bucket = "${var.project_name}-${var.owner_ra}-tfstate-${random_id.bucket_suffix.hex}"

  # Ambiente de laboratório: permite o destroy mesmo com versões do state no bucket.
  # Em produção, usar lifecycle { prevent_destroy = true }.
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.owner_ra}-tfstate"
  }
}

# Versionamento: histórico do state (permite rollback)
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encriptação server-side (SSE-S3 / AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueio total de acesso público ao bucket do state
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
