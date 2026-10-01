# API de Reservas — TechNova

**Aluno:** Rafael Nogueira Maruca  
**RA:** 6322006  
**Disciplina:** DevOps — Centro Universitário UniFAAT  
**Professor:** Alexandre Tavares  
**Avaliação:** Prova do Primeiro Bimestre (2026.2)

## Descrição do projeto

Ambiente completo e reproduzível da **API de Reservas** da TechNova: uma API Node.js/Express que gerencia reservas (`id`, `cliente`, `data`, `status`) com persistência em PostgreSQL.

O projeto cobre a jornada das Aulas 01 a 07:

- **Git** — versionamento com Conventional Commits e feature branches (`feature/api-reservas`, `feature/infra-terraform`, `feature/documentacao`) integradas com `merge --no-ff`
- **Docker** — imagem multi-stage da API executando como usuário não-root
- **Docker Compose** — ambiente local (API + PostgreSQL) subindo com um comando
- **Terraform** — infraestrutura AWS modularizada (VPC, Security Groups, EC2, RDS) com remote state (S3 + DynamoDB), no AWS Academy Learner Lab
- **IA como copiloto** — processo documentado em [`relatorio.md`](relatorio.md)

## API — rotas

| Método | Rota | Descrição |
|--------|------|-----------|
| `POST` | `/reservas` | Cria uma reserva (valida `cliente`, `data` no formato `YYYY-MM-DD` e `status` ∈ `pendente`, `confirmada`, `cancelada`) — `201` / `400` |
| `GET` | `/reservas` | Lista todas as reservas |
| `GET` | `/reservas/:id` | Busca uma reserva — `404` se não existir |
| `PUT` | `/reservas/:id` | Atualiza uma reserva — `404` se não existir |
| `DELETE` | `/reservas/:id` | Remove uma reserva (retorna a removida) — `404` se não existir |
| `GET` | `/health` | Health check (testa a conexão com o banco; `503` se indisponível) |

Os dados são gravados no **PostgreSQL** (Compose localmente; RDS na nuvem). A tabela `reservas` é criada pela própria API na inicialização (`CREATE TABLE IF NOT EXISTS`), o que funciona igual no Compose e no RDS.

## Estrutura

```
.
├── README.md
├── .gitignore
├── app/                     # API de Reservas (Node.js/Express)
│   ├── src/                 # server.js, db.js, routes/reservas.js
│   ├── package.json
│   ├── Dockerfile           # multi-stage, usuário não-root
│   └── .dockerignore
├── docker-compose.yml       # API + PostgreSQL (ambiente local)
├── .env.example
├── infra/                   # Terraform modularizado
│   ├── modules/{vpc,security-group,ec2,rds}/
│   ├── main.tf              # composição dos módulos
│   ├── variables.tf · outputs.tf
│   ├── providers.tf         # provider AWS + backend s3 (DynamoDB lock)
│   ├── user_data.sh         # inicialização da EC2 (Docker + API)
│   ├── terraform.tfvars.example
│   └── backend/             # S3 + DynamoDB do remote state
├── evidencias/              # build, compose ps, terraform plan, AWS, destroy, prints
└── relatorio.md             # relatório do processo com IA
```

## Ambiente local (Docker Compose)

Pré-requisitos: Docker Desktop com Compose v2.

```bash
cp .env.example .env        # defina POSTGRES_PASSWORD no .env
docker compose up -d --build
docker compose ps           # api e postgres devem aparecer como (healthy)
curl http://localhost:3000/health
curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"cliente":"Ana Souza","data":"2026-10-15","status":"pendente"}'
curl http://localhost:3000/reservas
docker compose down         # mantém o volume pgdata (dados persistem)
```

O Compose sobe a API e o PostgreSQL 15 em uma **rede bridge customizada** (`reservas-net`), com **volume nomeado** (`pgdata`), **healthcheck** no banco (`pg_isready`) e na API (`/health`), e `depends_on` com `condition: service_healthy`.

## Infraestrutura AWS (Terraform)

### Arquitetura

```
                Internet
                    │
             Internet Gateway
                    │
┌──────────────── VPC 10.0.0.0/16 (us-east-1) ─────────────────┐
│                                                              │
│  Subnets públicas (10.0.1.0/24 - 1a | 10.0.2.0/24 - 1b)      │
│   └── EC2 t2.micro  ── SG EC2: 22 e 3000                     │
│        Docker: api-reservas  (LabInstanceProfile / LabRole)  │
│                │ 5432 (SSL)                                  │
│                ▼                                             │
│  Subnets privadas (10.0.3.0/24 - 1a | 10.0.4.0/24 - 1b)      │
│   └── RDS PostgreSQL 15 db.t3.micro                          │
│        SG RDS: 5432 somente do SG da EC2                     │
│        publicly_accessible = false · storage_encrypted       │
└──────────────────────────────────────────────────────────────┘
Remote state: S3 (versionado + AES256) · Lock: DynamoDB (LockID)
```

### Módulos e composição

| Módulo | Cria | Outputs usados na composição |
|---|---|---|
| `modules/vpc` | VPC, IGW, subnets públicas/privadas (`for_each`), route table pública | `vpc_id`, `public_subnet_ids`, `private_subnet_ids` |
| `modules/security-group` | SG genérico (regras por CIDR e por SG de origem) | `sg_id` |
| `modules/ec2` | EC2 com `LabInstanceProfile` e user data | `public_ip`, `public_dns` |
| `modules/rds` | DB Subnet Group + RDS PostgreSQL privado e encriptado | `db_address`, `db_endpoint` |

`infra/main.tf`: `vpc` → `sg_ec2` / `sg_rds` (recebem `vpc_id`; o SG do RDS recebe o `sg_id` da EC2) → `rds` (subnets privadas) → `ec2` (subnet pública; o user data recebe o endereço do RDS).

### Restrições do AWS Academy Learner Lab

- Credenciais temporárias (Session Token) carregadas com `source aws-creds.sh` (arquivo fora do Git); região `us-east-1`.
- **Nenhum recurso IAM é criado**: a EC2 usa o instance profile pré-existente `LabInstanceProfile` (role `LabRole`).
- O Lab possui uma SCP que nega `s3:GetBucketObjectLockConfiguration`, usada pelo provider ao ler um `aws_s3_bucket`. Por isso o **bucket do state é criado/removido via AWS CLI**, e o Terraform (`infra/backend/`) gerencia o versionamento, a encriptação, o bloqueio de acesso público e a tabela DynamoDB. Os comandos estão documentados em `infra/backend/s3.tf`. *Na execução realizada, o bucket chegou a ser criado pelo `aws_s3_bucket` antes de o erro da SCP aparecer na leitura; ele foi então removido do state (`terraform state rm`) e mantido. A remoção via CLI foi executada e validada; a criação via CLI está documentada, mas não foi executada.*

### Como provisionar

```bash
source aws-creds.sh                      # credenciais do Learner Lab

# 1) Backend do remote state (antes do projeto principal)
cd infra/backend
terraform init
terraform apply -target=random_id.bucket_suffix
B=$(terraform output -raw s3_bucket_name)
aws s3api create-bucket --bucket "$B" --region us-east-1
aws s3api put-bucket-tagging --bucket "$B" --tagging 'TagSet=[{Key=Project,Value=technova},{Key=Environment,Value=dev},{Key=ManagedBy,Value=Terraform},{Key=Owner,Value=6322006},{Key=Purpose,Value="Terraform Remote State"}]'
terraform apply                          # versionamento, encriptação, bloqueio público, DynamoDB

# 2) Infraestrutura principal
cd ..
# ajuste o nome do bucket em providers.tf (bloco backend "s3") com o valor de $B
cp terraform.tfvars.example terraform.tfvars   # defina db_password (somente letras e números)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/prova-reservas-key -N ""
terraform init
terraform validate
terraform plan -out=main.tfplan
terraform apply main.tfplan
terraform output                         # ec2_public_ip, rds_endpoint, api_url
curl "$(terraform output -raw api_url)/health"
```

### Como destruir

```bash
cd infra && terraform destroy            # infraestrutura principal
cd backend && terraform destroy          # configs do bucket + DynamoDB
# remover as versões do state e o bucket: comandos em infra/backend/s3.tf
```

## Evidências

| Arquivo | Conteúdo |
|---|---|
| `evidencias/docker-build.txt` | `docker build` da imagem (exit code 0) |
| `evidencias/docker-run.txt` | container avulso (host 3001 → 3000, banco temporário) rodando como usuário `node`, `/health` e CRUD |
| `evidencias/compose-ps.txt` | `docker compose ps` (healthy), volume e rede, CRUD local, dados no PostgreSQL e o mesmo registro após `docker compose down` + `up` |
| `evidencias/terraform-validate.txt` | saída real de `terraform fmt -check` e `terraform validate` (infra e backend) |
| `evidencias/terraform-plan.txt` | `terraform plan` (15 recursos, 0 IAM) |
| `evidencias/aws-api-rds.txt` | API na EC2 gravando no RDS, `psql` no RDS, configuração do RDS/SG/EC2, state no S3 |
| `evidencias/terraform-destroy.txt` | destroy da infra e do backend; verificação de que nada restou |
| `evidencias/print-01-sts-identidade-e-terraform-output.png` | identidade do Learner Lab (`voclabs`) e `terraform output` |
| `evidencias/print-02-api-ec2-navegador.png` | `/reservas` da EC2 no navegador |
| `evidencias/print-03-api-curl-psql-rds-e-config-rds.png` | `curl` na API, `psql` no RDS (IP 10.0.3.250) e configuração do RDS |
| `evidencias/print-04-sg-rds-e-remote-state-s3-dynamodb.png` | SG do RDS (origem = SG da EC2), state no S3, versionamento, AES256 e DynamoDB |

## Limitações conhecidas

Pontos identificados na auditoria final que **não foram alterados**, porque o código precisa continuar idêntico ao que foi aplicado e evidenciado na AWS (corrigi-los exigiria um novo `apply` e novas evidências):

- **SSH (22) aberto para `0.0.0.0/0`** — segue o que o professor exigiu no TF da Aula 04 ("Porta `22` (TCP) — SSH — de `0.0.0.0/0`", `aula-04/TF.md`) e o que usa no código da Aula 05 (`aula-05/aula-05-rds/ec2.tf`). O laboratório da Aula 04 e o TA recomendam, em produção, restringir ao IP do administrador ("apenas do seu IP", `aula-04/TA.md`). O projeto já permite isso pela variável `ssh_allowed_cidrs` (ex.: `["SEU_IP/32"]`). Não alterei depois da execução para não divergir das evidências.
- **Senha do RDS no user data** — o `user_data.sh` grava as variáveis de conexão em `/opt/reservas/api.env` (`chmod 600`), mas o user data fica visível nos metadados da instância. Em produção: AWS Secrets Manager/SSM Parameter Store.
- **SSL sem validação de certificado** — a API conecta ao RDS com SSL (`DB_SSL=true`) e `rejectUnauthorized: false`; em produção, validar com o bundle de CA da AWS.
- **EC2 constrói a imagem a partir da branch `main`** no momento do boot (sem versão fixa); em produção, usar uma imagem publicada em registry com tag.
- **Bucket do state fora do Terraform** (SCP do Learner Lab): criação via CLI documentada mas não executada; `providers.tf` precisa ser ajustado com o nome do bucket.
- **`dynamodb_table` deprecado** no backend S3 do Terraform 1.16 (aviso no `init`/`plan`); mantido porque a prova exige DynamoDB para o locking.
- **`node:20-alpine`** segue o padrão das aulas; o Node.js 20 já está fora do período de suporte.
- **`.terraform.lock.hcl` não versionado**, seguindo o `.gitignore` das aulas.
