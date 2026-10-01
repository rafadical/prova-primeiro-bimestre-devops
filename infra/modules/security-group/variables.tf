variable "name" {
  description = "Nome do Security Group"
  type        = string
}

variable "description" {
  description = "Descrição do Security Group"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "ID da VPC onde o Security Group será criado"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (tags)"
  type        = string
}

variable "environment" {
  description = "Ambiente (tags)"
  type        = string
}

variable "ingress_cidr_rules" {
  description = "Regras de entrada liberadas por CIDR"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "ingress_sg_rules" {
  description = "Regras de entrada liberadas apenas para outros Security Groups (origem por SG)"
  type = list(object({
    from_port                 = number
    to_port                   = number
    protocol                  = string
    source_security_group_ids = list(string)
    description               = string
  }))
  default = []
}
