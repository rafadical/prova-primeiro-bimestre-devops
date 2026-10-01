# Tabela de locking do state: impede dois "terraform apply" simultâneos
resource "aws_dynamodb_table" "locks" {
  name         = "${var.project_name}-${var.owner_ra}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-${var.owner_ra}-terraform-locks"
  }
}
