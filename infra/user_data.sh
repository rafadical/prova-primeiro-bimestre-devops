#!/bin/bash
# ==================================================
# User data da EC2 — executa como root no primeiro boot.
# Instala Docker, clona o repositório, constrói a imagem
# da API e sobe o container conectado ao RDS.
# Log: /var/log/reservas-setup.log
# (Arquivo processado por templatefile(): valores entre
#  chaves são preenchidos pelo Terraform.)
# ==================================================
set -ex
exec > >(tee -a /var/log/reservas-setup.log) 2>&1

echo "== Instalando Docker e Git"
dnf install -y docker git
systemctl enable --now docker

echo "== Clonando o repositório"
git clone --depth 1 --branch ${repo_branch} ${repo_url} /opt/reservas

echo "== Construindo a imagem da API"
docker build -t api-reservas:1.0 /opt/reservas/app

echo "== Gerando variáveis de ambiente da API (conexão com o RDS)"
cat > /opt/reservas/api.env <<'EOF'
PORT=3000
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_SSL=true
EOF
chmod 600 /opt/reservas/api.env

echo "== Subindo o container da API"
docker run -d --name reservas-api --restart unless-stopped \
  -p 3000:3000 --env-file /opt/reservas/api.env api-reservas:1.0

echo "== Setup concluído"
