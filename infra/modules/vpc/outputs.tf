output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR da VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas (ordenados pela chave do mapa)"
  value       = [for k, s in aws_subnet.this : s.id if var.subnets[k].type == "public"]
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas (ordenados pela chave do mapa)"
  value       = [for k, s in aws_subnet.this : s.id if var.subnets[k].type == "private"]
}

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = aws_internet_gateway.main.id
}
