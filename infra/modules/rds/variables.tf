variable "project_name" {
  description = "Nome do projeto (nomes e tags)"
  type        = string
}

variable "environment" {
  description = "Ambiente (nomes e tags)"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_username" {
  description = "Usuário master do banco"
  type        = string
}

variable "db_password" {
  description = "Senha master do banco (somente letras e números, mínimo 8)"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Za-z0-9]{8,41}$", var.db_password))
    error_message = "db_password deve ter de 8 a 41 caracteres, somente letras e números (sem @, /, \" ou espaços)."
  }
}

variable "subnet_ids" {
  description = "IDs das subnets PRIVADAS do DB Subnet Group (em pelo menos 2 AZs)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "IDs dos Security Groups do RDS"
  type        = list(string)
}

variable "instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "engine_version" {
  description = "Versão principal do PostgreSQL"
  type        = string
  default     = "15"
}

variable "allocated_storage" {
  description = "Armazenamento em GB"
  type        = number
  default     = 20
}
