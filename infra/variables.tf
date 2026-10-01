# ---------- Geral ----------
variable "aws_region" {
  description = "Região AWS (AWS Academy Learner Lab usa us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (nomes e tags)"
  type        = string
  default     = "technova"
}

variable "environment" {
  description = "Ambiente (nomes e tags)"
  type        = string
  default     = "dev"
}

variable "owner_ra" {
  description = "RA do aluno responsável (tag Owner)"
  type        = string
  default     = "6322006"
}

# ---------- Rede ----------
variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "Subnets públicas e privadas em 2 AZs"
  type = map(object({
    cidr = string
    az   = string
    type = string
  }))
  default = {
    "public-1"  = { cidr = "10.0.1.0/24", az = "us-east-1a", type = "public" }
    "public-2"  = { cidr = "10.0.2.0/24", az = "us-east-1b", type = "public" }
    "private-1" = { cidr = "10.0.3.0/24", az = "us-east-1a", type = "private" }
    "private-2" = { cidr = "10.0.4.0/24", az = "us-east-1b", type = "private" }
  }
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs com acesso SSH (porta 22) à EC2. Em produção, restringir ao IP do administrador"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ---------- EC2 ----------
variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "ssh_public_key_path" {
  description = "Caminho da chave pública SSH registrada no key pair"
  type        = string
  default     = "~/.ssh/prova-reservas-key.pub"
}

variable "repo_url" {
  description = "Repositório público clonado pela EC2 para construir a API"
  type        = string
  default     = "https://github.com/rafadical/prova-primeiro-bimestre-devops.git"
}

variable "repo_branch" {
  description = "Branch do repositório usada pela EC2"
  type        = string
  default     = "main"
}

# ---------- RDS ----------
variable "db_name" {
  description = "Nome do banco de dados da API"
  type        = string
  default     = "reservas"
}

variable "db_username" {
  description = "Usuário master do RDS"
  type        = string
  default     = "technova_admin"
}

variable "db_password" {
  description = "Senha master do RDS (definida em terraform.tfvars, que não é versionado)"
  type        = string
  sensitive   = true
}
