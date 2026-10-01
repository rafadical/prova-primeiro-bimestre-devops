variable "instance_name" {
  description = "Nome da instância EC2 (tag Name)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID da AMI (obtido via data source no root)"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet (pública) onde a instância será criada"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de IDs de Security Groups"
  type        = list(string)
}

variable "key_name" {
  description = "Nome do key pair para acesso SSH"
  type        = string
}

variable "iam_instance_profile" {
  description = "Instance profile pré-existente do AWS Academy Learner Lab (não criamos IAM)"
  type        = string
  default     = "LabInstanceProfile"
}

variable "user_data" {
  description = "Script de inicialização (user data)"
  type        = string
  default     = ""
}
