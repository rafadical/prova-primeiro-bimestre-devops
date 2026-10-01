# ==================================================
# Módulo RDS: PostgreSQL privado, encriptado, nas subnets
# privadas (DB Subnet Group com 2 AZs). Acesso controlado
# pelos Security Groups recebidos (somente a EC2).
# ==================================================

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-${var.environment}-db"

  engine         = "postgres"
  engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  # Rede: somente subnets privadas e sem IP público
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false

  # Segurança e custos do laboratório
  storage_encrypted = true
  multi_az          = false

  backup_retention_period      = 7
  performance_insights_enabled = false

  # Laboratório: destroy sem snapshot final (NÃO fazer em produção)
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-rds"
  }
}
