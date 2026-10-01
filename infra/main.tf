# ==================================================
# Composição dos módulos — API de Reservas na AWS
# VPC -> Security Groups -> RDS -> EC2
# (o output de um módulo alimenta o input do próximo)
# Ambiente: AWS Academy Learner Lab (sem criação de IAM)
# ==================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# AMI Amazon Linux 2023 mais recente (nunca fixar ID)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key pair a partir da chave pública local (a privada nunca vai para o Git)
resource "aws_key_pair" "api" {
  key_name   = "${local.name_prefix}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# ---------- Módulo 1: Rede ----------
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
  subnets      = var.subnets
}

# ---------- Módulo 2: Security Group da EC2 (SSH 22 + API 3000) ----------
module "sg_ec2" {
  source = "./modules/security-group"

  name         = "${local.name_prefix}-ec2-sg"
  description  = "EC2 da API de Reservas: SSH (22) e API (3000)"
  vpc_id       = module.vpc.vpc_id # <- output do módulo vpc
  project_name = var.project_name
  environment  = var.environment

  ingress_cidr_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
      description = "SSH"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "API de Reservas"
    }
  ]
}

# ---------- Módulo 3: Security Group do RDS (5432 apenas do SG da EC2) ----------
module "sg_rds" {
  source = "./modules/security-group"

  name         = "${local.name_prefix}-rds-sg"
  description  = "RDS PostgreSQL: 5432 somente a partir do SG da EC2"
  vpc_id       = module.vpc.vpc_id # <- output do módulo vpc
  project_name = var.project_name
  environment  = var.environment

  ingress_sg_rules = [
    {
      from_port                 = 5432
      to_port                   = 5432
      protocol                  = "tcp"
      source_security_group_ids = [module.sg_ec2.sg_id] # <- output do módulo sg_ec2
      description               = "PostgreSQL somente da EC2"
    }
  ]
}

# ---------- Módulo 4: RDS PostgreSQL nas subnets privadas ----------
module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  environment        = var.environment
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids # <- output do módulo vpc
  security_group_ids = [module.sg_rds.sg_id]         # <- output do módulo sg_rds
}

# ---------- Módulo 5: EC2 com a API na subnet pública ----------
module "ec2" {
  source = "./modules/ec2"

  instance_name        = "${local.name_prefix}-api"
  instance_type        = var.instance_type
  ami_id               = data.aws_ami.amazon_linux.id
  subnet_id            = module.vpc.public_subnet_ids[0] # <- output do módulo vpc
  security_group_ids   = [module.sg_ec2.sg_id]           # <- output do módulo sg_ec2
  key_name             = aws_key_pair.api.key_name
  iam_instance_profile = "LabInstanceProfile" # pré-existente no Learner Lab

  # Script de inicialização recebe o endereço do RDS (output do módulo rds).
  # replace() garante quebras de linha LF mesmo se o arquivo vier com CRLF do Windows.
  user_data = replace(templatefile("${path.module}/user_data.sh", {
    repo_url    = var.repo_url
    repo_branch = var.repo_branch
    db_host     = module.rds.db_address # <- output do módulo rds
    db_port     = module.rds.db_port
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = var.db_password
  }), "\r\n", "\n")
}
