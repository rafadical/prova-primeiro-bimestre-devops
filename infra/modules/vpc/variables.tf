variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado em nomes e tags)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "subnets" {
  description = "Mapa de subnets: chave => { cidr, az, type = \"public\" | \"private\" }"
  type = map(object({
    cidr = string
    az   = string
    type = string
  }))

  validation {
    condition     = alltrue([for s in values(var.subnets) : contains(["public", "private"], s.type)])
    error_message = "O campo type de cada subnet deve ser \"public\" ou \"private\"."
  }
}
