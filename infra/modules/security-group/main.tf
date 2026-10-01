# ==================================================
# Módulo Security Group genérico: regras de entrada por
# CIDR e/ou por Security Group de origem; saída liberada.
# ==================================================

resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  # Entrada por faixa de IP (ex.: SSH e API)
  dynamic "ingress" {
    for_each = var.ingress_cidr_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Entrada apenas a partir de outro Security Group (ex.: RDS <- EC2)
  dynamic "ingress" {
    for_each = var.ingress_sg_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.source_security_group_ids
    }
  }

  # Saída: todo tráfego permitido
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}
