# ==================================================
# Módulo EC2: instância na subnet pública usando o
# instance profile pré-existente do Learner Lab
# (LabInstanceProfile / LabRole) — nenhum recurso IAM é criado.
# ==================================================

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile

  user_data = var.user_data != "" ? var.user_data : null

  # Se o script de inicialização mudar, a instância é recriada
  user_data_replace_on_change = true

  tags = {
    Name = var.instance_name
  }
}
