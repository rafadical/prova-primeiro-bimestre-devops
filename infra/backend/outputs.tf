output "s3_bucket_name" {
  description = "Nome do bucket S3 do state (usar no backend \"s3\" de infra/providers.tf)"
  value       = aws_s3_bucket.state.id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3 do state"
  value       = aws_s3_bucket.state.arn
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB de locking (usar em dynamodb_table do backend)"
  value       = aws_dynamodb_table.locks.name
}

output "aws_region" {
  description = "Região do backend"
  value       = var.aws_region
}
