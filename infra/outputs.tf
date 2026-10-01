# ---------- Saídas exigidas pela prova ----------
output "ec2_public_ip" {
  description = "IP público da EC2"
  value       = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "Endpoint do RDS (host:porta)"
  value       = module.rds.db_endpoint
}

output "api_url" {
  description = "URL da API de Reservas"
  value       = "http://${module.ec2.public_ip}:3000"
}

# ---------- Saídas auxiliares ----------
output "ec2_public_dns" {
  description = "DNS público da EC2"
  value       = module.ec2.public_dns
}

output "rds_address" {
  description = "Hostname do RDS (sem porta)"
  value       = module.rds.db_address
}

output "ssh_command" {
  description = "Comando para acessar a EC2 via SSH"
  value       = "ssh -i ~/.ssh/prova-reservas-key ec2-user@${module.ec2.public_ip}"
}

output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "ec2_security_group_id" {
  description = "ID do Security Group da EC2"
  value       = module.sg_ec2.sg_id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = module.sg_rds.sg_id
}
