variable "aws_region" {
  description = "Região AWS (AWS Academy Learner Lab usa us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (usado em nomes e tags)"
  type        = string
  default     = "technova"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}

variable "owner_ra" {
  description = "RA do aluno responsável (tag Owner e sufixo dos nomes)"
  type        = string
  default     = "6322006"
}
