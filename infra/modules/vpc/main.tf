# ==================================================
# Módulo VPC: VPC + Internet Gateway + subnets dinâmicas
# (for_each) + Route Table pública associada às públicas.
# Subnets privadas usam a route table padrão (sem internet).
# ==================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# Uma subnet para cada entrada do mapa var.subnets
resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.type == "public"

  tags = {
    Name = "${var.project_name}-${var.environment}-${each.key}"
    Type = each.value.type
  }
}

# Route table pública: todo tráfego externo sai pelo Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

locals {
  public_subnets = { for k, s in var.subnets : k => s if s.type == "public" }
}

# Associa a route table pública apenas às subnets públicas
resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}
