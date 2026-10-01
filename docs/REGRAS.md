# REGRAS.md — Regras da Prova do 1º Bimestre (DevOps)

> Este arquivo contém **apenas** regras referentes à prova. As aulas 01–07 entram só para confirmar **como** fazer o que a prova pede.
> - Fonte principal: `provas/prova-primeiro-bimestre.md` (abreviado **PROVA**), no repositório `AleTavares/devops_20262`, commit `aa8a051`.
> - Consultar este arquivo antes de qualquer alteração na solução. Atualizar sempre que surgir uma regra nova (ver o histórico no final).

## Etiquetas

| Etiqueta | Significado |
|---|---|
| **[EXIGÊNCIA DA PROVA]** | Está escrito explicitamente no enunciado (`PROVA`) |
| **[CONFIRMADO PELAS AULAS]** | A prova pede; as aulas mostram como o professor faz |
| **[INFERÊNCIA]** | Não está escrito explicitamente; tratar com cautela |

> Observação: algumas regras vêm do **corretor automático do professor**:
> - `.github/scripts/avaliar_pr.py` (abreviado **BOT**)
> - `.github/workflows/avaliar-pr-tf.yml` (abreviado **WF**)
>
> Como não estão no enunciado, aparecem como **[INFERÊNCIA]**, com a origem indicada. São regras de alto impacto e devem ser seguidas.

---

## 1. Requisitos obrigatórios

### 1.1 Aplicação — API de Reservas
- **[EXIGÊNCIA DA PROVA]** Node.js/Express; recurso `reservas` com os campos `id`, `cliente`, `data`, `status`.
  *Origem: PROVA › "O Que Construir"*
- **[EXIGÊNCIA DA PROVA]** Rotas:

  | Método | Rota | Obrigação |
  |---|---|---|
  | POST | `/reservas` | Cria e **valida campos obrigatórios** |
  | GET | `/reservas` | Lista todas |
  | GET | `/reservas/:id` | Busca; **404 se não existir** |
  | PUT | `/reservas/:id` | Atualiza existente |
  | DELETE | `/reservas/:id` | Remove |
  | GET | `/health` | Health check, *"usado pelo healthcheck do Compose"* |

  *Origem: PROVA › "Rotas obrigatórias (CRUD completo)"*
- **[EXIGÊNCIA DA PROVA]** O CRUD **lê e grava no PostgreSQL, não em memória**, tanto local (Compose) quanto na nuvem (RDS).
  *Origem: PROVA › "Importante" após a tabela de rotas*

### 1.2 Parte 1 — Git
- **[EXIGÊNCIA DA PROVA]** Repositório **público** no GitHub chamado **`prova-primeiro-bimestre-devops`**.
- **[EXIGÊNCIA DA PROVA]** **No mínimo 6 commits** em Conventional Commits (`feat:`, `docs:`, `fix:`, `chore:`).
- **[EXIGÊNCIA DA PROVA]** Uso de **feature branch + merge**.
- **[EXIGÊNCIA DA PROVA]** `README.md` na raiz com **nome, RA e descrição do projeto**.
- **[EXIGÊNCIA DA PROVA]** `.gitignore` com `node_modules`, `.env`, `.terraform`, `*.tfstate`, `*.pem`.

*Origem: PROVA › Parte 1*

### 1.3 Parte 2 — Docker
- **[EXIGÊNCIA DA PROVA]** `Dockerfile` funcional da API (multi-stage **recomendado**, usuário **não-root**).
- **[EXIGÊNCIA DA PROVA]** `.dockerignore` configurado.
- **[EXIGÊNCIA DA PROVA]** Evidência de build e de execução do container.

*Origem: PROVA › Parte 2*

### 1.4 Parte 3 — Docker Compose
- **[EXIGÊNCIA DA PROVA]** `docker-compose.yml` subindo **API + PostgreSQL**.
- **[EXIGÊNCIA DA PROVA]** **Volume nomeado** para o banco.
- **[EXIGÊNCIA DA PROVA]** **Rede bridge customizada**.
- **[EXIGÊNCIA DA PROVA]** **Healthcheck no banco**.
- **[EXIGÊNCIA DA PROVA]** **`depends_on` com condição**.
- **[EXIGÊNCIA DA PROVA]** `.env.example` versionado (sem senhas reais) e `.env` no `.gitignore`.
- **[EXIGÊNCIA DA PROVA]** O ambiente local sobe **com um comando**.

*Origem: PROVA › Parte 3; Narrativa; checklist do `entrega.md`*

### 1.5 Parte 4 — Terraform, Módulos e Remote State
- **[EXIGÊNCIA DA PROVA]** Terraform **modularizado**, executado no **AWS Academy Learner Lab**.
- **[EXIGÊNCIA DA PROVA]** Módulo **`vpc`**: subnets **públicas e privadas em 2 AZs**.
- **[EXIGÊNCIA DA PROVA]** Módulo **`security-group`**, com menor privilégio:
  - EC2: portas **22** e **3000**
  - RDS: porta **5432 apenas a partir do SG da EC2**
- **[EXIGÊNCIA DA PROVA]** Módulo **`ec2`**:
  - **t2.micro**, na subnet **pública**, rodando a API
  - `LabInstanceProfile` se precisar de acesso a serviços
- **[EXIGÊNCIA DA PROVA]** Módulo **`rds`**:
  - PostgreSQL **db.t3.micro**, **provisionado e funcional**, nas subnets **privadas**
  - é o banco da API na nuvem
  - `publicly_accessible = false`
  - `storage_encrypted = true`
  - `db_subnet_group_name` com as subnets privadas
  - acesso **apenas** do SG da EC2 na porta 5432
- **[EXIGÊNCIA DA PROVA]** Remote State: backend **S3 com versionamento e encriptação** + **DynamoDB** para locking.
- **[EXIGÊNCIA DA PROVA]** **Composição entre módulos** (o output de um alimenta o input de outro).
- **[EXIGÊNCIA DA PROVA]** **Tags em todos os recursos**.
- **[EXIGÊNCIA DA PROVA]** Outputs: **IP da EC2**, **endpoint do RDS**, **URL da API**.
- **[EXIGÊNCIA DA PROVA]** `terraform validate` e `terraform plan` **sem erros**.

*Origem: PROVA › Parte 4; checklist do `entrega.md`*

### 1.6 Parte 5 — IA como copiloto
- **[EXIGÊNCIA DA PROVA]** Usar Kiro (Spec-Driven) **ou outra LLM** para gerar **parte** da solução (Dockerfile, docker-compose, módulos Terraform).
- **[EXIGÊNCIA DA PROVA]** Documentar o processo no relatório.
- **[EXIGÊNCIA DA PROVA]** Cada decisão da IA precisa ser **entendida e validada** pelo aluno.

*Origem: PROVA › Parte 5; Narrativa (fala da Marina)*

### 1.7 Parte 6 — `relatorio.md`
- **[EXIGÊNCIA DA PROVA]** Relatório **dissertativo**, **no mínimo 10 linhas por questão**, baseado na experiência real.
- **[EXIGÊNCIA DA PROVA]** **Informar no início qual ferramenta de IA foi usada.**
- **[EXIGÊNCIA DA PROVA]** As 4 questões:
  - **Q1 — Jornada completa:** como as peças se conectaram, do Git ao Terraform com módulos e remote state; a ordem seguida e por quê; onde cada aula (01 a 07) aparece na solução.
  - **Q2 — Processo com IA:** qual ferramenta e como foi usada; os prompts principais; o que a IA gerou bem e o que precisou ser corrigido; o fluxo requisitos → design → tarefas, se tiver usado Kiro Spec; comparação com fazer manualmente (onde economizou tempo, onde atrapalhou).
  - **Q3 — Infraestrutura, segurança e Learner Lab:** a arquitetura provisionada (pode ter diagrama); por que o RDS fica na subnet privada e a EC2 na pública; como funcionou o `LabRole`/`LabInstanceProfile` em vez de criar IAM; que ajustes o Learner Lab exigiu (credenciais temporárias, região, restrições de IAM).
  - **Q4 — Validação e responsabilidade:** o checklist aplicado antes do `apply` em código gerado por IA; como foi validado que a infra estava correta e segura; o que aconteceria se o código da IA fosse aceito sem revisão; como a evolução Git → Docker → Terraform → Modules preparou para usar IA com responsabilidade.

*Origem: PROVA › "Relatório do Processo (relatorio.md) — 4 Questões"*

---

## 2. Arquivos que precisam ser criados

| Arquivo / pasta | Etiqueta | Origem |
|---|---|---|
| `README.md` (raiz) | [EXIGÊNCIA DA PROVA] | PROVA › Parte 1 e Estrutura |
| `.gitignore` (raiz) | [EXIGÊNCIA DA PROVA] | PROVA › Parte 1 e Regras 7 |
| `app/src/` (código da API) | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `app/package.json` | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `app/Dockerfile` | [EXIGÊNCIA DA PROVA] | PROVA › Parte 2 e Estrutura |
| `app/.dockerignore` | [EXIGÊNCIA DA PROVA] | PROVA › Parte 2 e Estrutura |
| `docker-compose.yml` (raiz) | [EXIGÊNCIA DA PROVA] | PROVA › Parte 3 e Estrutura |
| `.env.example` (raiz) | [EXIGÊNCIA DA PROVA] | PROVA › Parte 3 e Estrutura |
| `infra/main.tf` (composição dos módulos) | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `infra/variables.tf` | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `infra/outputs.tf` | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `infra/providers.tf` (provider AWS + backend S3) | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `infra/modules/vpc/` | [EXIGÊNCIA DA PROVA] | PROVA › Parte 4 e Estrutura |
| `infra/modules/security-group/` | [EXIGÊNCIA DA PROVA] | PROVA › Parte 4 e Estrutura |
| `infra/modules/ec2/` | [EXIGÊNCIA DA PROVA] | PROVA › Parte 4 e Estrutura |
| `infra/modules/rds/` | [EXIGÊNCIA DA PROVA] | PROVA › Parte 4 e Estrutura |
| `infra/backend/` (S3 + DynamoDB) | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `evidencias/docker-build.txt` (ou screenshot) | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `evidencias/compose-ps.txt` | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `evidencias/terraform-plan.txt` | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `relatorio.md` (raiz) | [EXIGÊNCIA DA PROVA] | PROVA › Parte 6 e Estrutura |
| `entregas/provaPrimeiroBi/SEU-RA/entrega.md` (no **fork** da disciplina) | [EXIGÊNCIA DA PROVA] | PROVA › "Como Entregar" |
| `main.tf`, `variables.tf`, `outputs.tf` dentro de cada módulo | [CONFIRMADO PELAS AULAS] | `aula-06/README.md` › "Estrutura Padrão de um Módulo"; `aula-06/TF.md` |
| Arquivos do backend: `main.tf`, `s3.tf`, `dynamodb.tf`, `outputs.tf`, `variables.tf` | [CONFIRMADO PELAS AULAS] | `aula-05/aula-05-backend/` |
| Script de inicialização da EC2 em arquivo separado (`user_data.sh`) lido com `file()` | [CONFIRMADO PELAS AULAS] | `aula-04/laboratorio-parte2.md` › 2.1 |
| `terraform.tfvars.example` (sem senha real) | [CONFIRMADO PELAS AULAS] | `aula-05/aula-05-rds/terraform.tfvars.example` |
| Script de schema/tabela (ex.: `init.sql`) | [INFERÊNCIA] — necessário para o Postgres local (`aula-02/laboratorio-parte1.md` › Parte 4), mas **não cria a tabela no RDS** |

---

## 3. Estrutura exigida

**[EXIGÊNCIA DA PROVA]** *Origem: PROVA › "Estrutura do Repositório do Aluno"*
```
prova-primeiro-bimestre-devops/
├── README.md
├── .gitignore
├── app/
│   ├── src/
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
├── docker-compose.yml
├── .env.example
├── infra/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── security-group/
│   │   ├── ec2/
│   │   └── rds/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── backend/
├── evidencias/
│   ├── docker-build.txt
│   ├── compose-ps.txt
│   ├── terraform-plan.txt
│   └── (screenshots opcionais)
└── relatorio.md
```

- **[INFERÊNCIA]** O corretor automático verifica nomes **exatos** na branch padrão:
  - na raiz: `README.md`, `.gitignore`, `docker-compose.yml`, `relatorio.md`
  - as pastas `app/` e `infra/`
  - `app/Dockerfile`
  - `infra/modules/{vpc,security-group,ec2,rds}`

  *Origem: BOT › `PROVA_ESTRUTURA`, `precheck_prova()`*
- **[INFERÊNCIA]** A IA do corretor lê **apenas** `README.md`, `docker-compose.yml`, `relatorio.md`, `infra/main.tf`, `infra/providers.tf` e `infra/outputs.tf`, com limite de 60 KB no total.
  - A composição dos módulos e o backend S3 precisam ficar evidentes nesses arquivos.

  *Origem: BOT › `collect_prova_sources()`*
- **[INFERÊNCIA]** `infra/` é um **único root module**. Não usar `environments/dev|staging`, que era a estrutura do TF 06 e não está na prova.
  *Origem: PROVA › Estrutura × `aula-06/TF.md`*
- **[INFERÊNCIA]** `infra/backend/` é um root separado, com state local próprio, que precisa ficar fora do Git.
  *Origem: padrão `aula-05/aula-05-backend/`*

---

## 4. Comandos necessários

| Comando | Para quê, na prova | Etiqueta | Origem |
|---|---|---|---|
| `git checkout -b feature/<nome>` · `git checkout main` · `git merge feature/<nome>` | Feature branch + merge | [EXIGÊNCIA DA PROVA] (o workflow) · [CONFIRMADO PELAS AULAS] (os comandos) | PROVA › Parte 1; `aula-01/laboratorio-parte1.md` › Parte 4 |
| `git push origin feature/<nome>` | Manter a branch como evidência do workflow | [CONFIRMADO PELAS AULAS] | `aula-01/TF.md` › passo 10 |
| `git log --oneline --graph --all` | Conferir ≥ 6 commits e o merge | [CONFIRMADO PELAS AULAS] | `aula-01/laboratorio-parte1.md` › 4.9 |
| `git status` · `git ls-files` | Garantir que nada proibido foi versionado | [CONFIRMADO PELAS AULAS] | `aula-02/TF.md` › 9.1; `aula-03/laboratorio-parte1.md` › 7.3 |
| `docker build -t <nome>:<tag> ./app` | Evidência de build (`evidencias/docker-build.txt`) | [EXIGÊNCIA DA PROVA] (evidência) · [CONFIRMADO PELAS AULAS] (comando) | PROVA › Parte 2; `aula-01/laboratorio-parte2.md` › 4.1 |
| `docker run -d --name X -p 3000:3000 <img>` · `docker ps` · `docker logs X` | Evidência de execução do container | [CONFIRMADO PELAS AULAS] | `aula-01/laboratorio-parte2.md` › 4.4–4.8 |
| `docker compose config` | Validar o YAML (inclusive o gerado pela IA) | [CONFIRMADO PELAS AULAS] | `aula-02/README.md` › Checklist de validação |
| `docker compose up -d --build` | Subir tudo com um comando | [EXIGÊNCIA DA PROVA] (um comando) · [CONFIRMADO PELAS AULAS] | PROVA › checklist; `aula-02/laboratorio-parte1.md` › 3.6 |
| `docker compose ps` | Evidência `evidencias/compose-ps.txt` (healthy) | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura |
| `docker compose exec postgres psql -U <u> -d <db> -c "SELECT * FROM reservas;"` | Provar que o CRUD grava no Postgres | [CONFIRMADO PELAS AULAS] | `aula-02/laboratorio-parte1.md` › 4.1 |
| `docker compose down` (sem `-v`) + `up` | Provar persistência no volume | [CONFIRMADO PELAS AULAS] | `aula-02/laboratorio-parte1.md` › 4.4–4.5 |
| `source aws-creds.sh` · `aws sts get-caller-identity` | Carregar e validar as credenciais temporárias (Session Token) | [EXIGÊNCIA DA PROVA] (credencial temporária) · [CONFIRMADO PELAS AULAS] | PROVA › Ambiente AWS; `aula-04/laboratorio-parte1.md` › Parte 0 |
| `terraform init` · `apply` em `infra/backend/` | Criar S3 + DynamoDB **antes** do backend | [EXIGÊNCIA DA PROVA] (a ordem) · [CONFIRMADO PELAS AULAS] | PROVA › Dicas; `aula-05/laboratorio-parte2.md` › Parte 3 |
| `terraform init` (ou `-migrate-state`) em `infra/` | Inicializar com o backend S3 | [CONFIRMADO PELAS AULAS] | `aula-05/laboratorio-parte2.md` › 4.4 |
| `terraform fmt` · `terraform validate` | Validar sintaxe | [EXIGÊNCIA DA PROVA] (validate) · [CONFIRMADO PELAS AULAS] (fmt) | PROVA › checklist; `aula-03/TF.md` › Regras 4–5 |
| `terraform plan > ../evidencias/terraform-plan.txt` | Evidência do plan | [EXIGÊNCIA DA PROVA] | PROVA › Estrutura e checklist |
| `terraform apply` · `terraform output` | Provisionar; obter IP da EC2, endpoint do RDS, URL | [EXIGÊNCIA DA PROVA] (RDS funcional + outputs) | PROVA › Parte 4 |
| `aws s3 ls s3://<bucket>/<key>` | Evidência do state no S3 | [CONFIRMADO PELAS AULAS] | `aula-05/TF.md` › Evidências 1 |
| `curl http://<IP>:3000/health` · `curl ... /reservas` | Provar a API na EC2 gravando no RDS | [INFERÊNCIA] — a prova pede o RDS "funcional"; o teste com `curl` vem de `aula-04/laboratorio-parte2.md` › 4.3 |
| `terraform destroy` em `infra/` **e** em `infra/backend/` | Liberar os recursos após as evidências | [EXIGÊNCIA DA PROVA] (destroy) · [CONFIRMADO PELAS AULAS] (backend por último) | PROVA › Regras 6; `aula-05/laboratorio-parte2.md` › Parte 7 |

---

## 5. Regras de implementação

### 5.1 API
- **[CONFIRMADO PELAS AULAS]** Configuração por variáveis de ambiente: `PORT`, `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`.
  *Origem: `aula-02/laboratorio-parte1.md` › 1.3*
- **[CONFIRMADO PELAS AULAS]** API escutando na porta **3000** (é a porta que a prova abre no SG).
  *Origem: PROVA › Parte 4; aulas 01–05*
- **[INFERÊNCIA]** A tabela `reservas` precisa existir também no **RDS**. O `init.sql` do Compose não roda lá: criar o schema pela aplicação ou executar o SQL via `psql` a partir da EC2.
- **[INFERÊNCIA]** Para o host do banco no RDS, usar o atributo **`address`**, porque `endpoint` vem como `host:5432`.
  *Origem: `aula-05/aula-05-rds/outputs.tf`*
- **[INFERÊNCIA]** O RDS PostgreSQL 15 exige **SSL** por padrão. O driver `pg` do Node precisa ser configurado para isso. As aulas não cobrem esse ponto, então convém testar cedo.
- **[INFERÊNCIA]** Os códigos de status não estão definidos na prova, exceto o 404. As aulas usam **201** no POST como exemplo de requisito.
  *Origem: `aula-02/laboratorio-parte2.md` › 2.3*

### 5.2 Dockerfile
- **[CONFIRMADO PELAS AULAS]** Base `node:20-alpine`; `COPY package*.json` **antes** do código (cache de camadas); `EXPOSE 3000`.
  *Origem: `aula-01/laboratorio-parte2.md` › 3.4–3.5*
- **[CONFIRMADO PELAS AULAS]** Multi-stage e usuário não-root aparecem nas aulas apenas como correção pedida ao Kiro.
  *Origem: `aula-02/laboratorio-parte2.md` › 3.3 e Validação Final*

### 5.3 docker-compose.yml
- **[CONFIRMADO PELAS AULAS]** Postgres com `postgres:15-alpine` e volume `pgdata:/var/lib/postgresql/data`; rede `driver: bridge`; a API acessa o banco pelo **nome do serviço**.
  *Origem: `aula-02/laboratorio-parte1.md` › 2.1–2.4*
- **[CONFIRMADO PELAS AULAS]** Healthcheck `pg_isready -U <user> -d <db>` + `depends_on: { <db>: { condition: service_healthy } }`.
  *Origem: `aula-02/laboratorio-parte1.md` › 6.1–6.2*
- **[CONFIRMADO PELAS AULAS]** Variáveis interpoladas a partir do `.env` (`${VAR}`); `restart: unless-stopped`.
  *Origem: `aula-02/laboratorio-parte1.md` › 2.3; `aula-02/TF.md` › 5.5*
- **[INFERÊNCIA]** Healthcheck **também na API** (`/health`), já que a prova diz que essa rota é "usada pelo healthcheck do Compose". A imagem alpine tem `wget`, mas não `curl`.
- **[INFERÊNCIA]** Não colocar senha como valor padrão no YAML (o lab faz `${POSTGRES_PASSWORD:-technova_dev_2024}`), porque a prova pede "sem senhas reais".

### 5.4 Terraform
- **[CONFIRMADO PELAS AULAS]** `providers.tf` com `required_version >= 1.0`, `hashicorp/aws ~> 5.0` e `region = "us-east-1"`.
  *Origem: `aula-03/laboratorio-parte1.md` › 3.2*
- **[CONFIRMADO PELAS AULAS]** Bloco `backend "s3"` com `bucket`, `key`, `region`, `encrypt = true`, `dynamodb_table`.
  *Origem: `aula-05/aula-05-rds/providers.tf`*
- **[CONFIRMADO PELAS AULAS]** Backend:
  - S3 com `aws_s3_bucket_versioning` (Enabled)
  - encriptação server-side (o professor usou KMS)
  - Public Access Block com as 4 opções em `true`
  - nome único com `random_id`
  - DynamoDB com `hash_key = "LockID"` (tipo `S`) e `PAY_PER_REQUEST`

  *Origem: `aula-05/aula-05-backend/s3.tf`, `dynamodb.tf`*
- **[CONFIRMADO PELAS AULAS]** Módulo VPC com subnets por `for_each` (mapa com cidr/az/type), IGW e route table pública **associada**, e outputs `vpc_id`, `public_subnet_ids`, `private_subnet_ids`.
  *Origem: `aula-06/TF.md` › Requisito 1; `aula-06/laboratorio-parte2.md` › Parte 1*
- **[CONFIRMADO PELAS AULAS]** Módulo SG genérico (regras como lista de objetos), com output `sg_id`.
  *Origem: `aula-06/TF.md` › Requisito 2*
- **[INFERÊNCIA]** Esse módulo precisa aceitar um **SG de origem** (`security_groups` / `source_security_group_id`), porque o da aula 06 só aceita CIDR. A referência por SG aparece em `aula-06/trabalho-em-aula.md` e em `aula-05/README.md` › 5.
- **[CONFIRMADO PELAS AULAS]** EC2:
  - AMI via `data "aws_ami"` (Amazon Linux 2023), **nunca ID fixo**
  - `iam_instance_profile = "LabInstanceProfile"`
  - `aws_key_pair` com `file()`
  - `user_data` em arquivo separado

  *Origem: `aula-04/laboratorio-parte2.md` › 2.1 e Checklist*
- **[INFERÊNCIA]** O `user_data` precisa subir a API **conectada ao RDS** (com `DB_HOST` etc.). A forma de deploy é livre: Node direto, como na aula 04, ou Docker.
- **[CONFIRMADO PELAS AULAS]** RDS:
  - `engine = "postgres"`, `engine_version = "15"`, `allocated_storage = 20`, `gp2`
  - `multi_az = false`, `skip_final_snapshot = true`
  - DB Subnet Group com **2 subnets privadas em AZs diferentes**

  *Origem: `aula-05/aula-05-rds/rds.tf`; `aula-05/README.md` › 4*
- **[CONFIRMADO PELAS AULAS]** `db_password` com `sensitive = true`, valor em `terraform.tfvars` (fora do Git); senha **sem `@`, `/` ou `"`**.
  *Origem: `aula-05/laboratorio-parte1.md` › 1.2–1.4; `aula-06/TF.md` › Dicas 5*
- **[CONFIRMADO PELAS AULAS]** Composição:
  - `module.vpc.vpc_id` → SGs
  - `public_subnet_ids[0]` → EC2
  - `private_subnet_ids` → RDS
  - `sg_id` → EC2 e RDS

  *Origem: `aula-06/TF.md` › Requisito 5*
- **[CONFIRMADO PELAS AULAS]** Tags `Name`, `Project`, `Environment`, `ManagedBy` + identificação do aluno (`Owner`/`RA`). `default_tags` no provider é uma forma ensinada.
  *Origem: `aula-04/TF.md` › 7; `aula-04/laboratorio-parte1.md` › 1.1; `aula-06/TF.md` › Checklist*
- **[INFERÊNCIA]** O bloco `backend "s3"` **não aceita variáveis**: o nome do bucket entra literal ou via `-backend-config`.
  *Origem: o professor usa literal em `aula-05/aula-05-rds/providers.tf`*
- **[INFERÊNCIA]** Usar `LabInstanceProfile` de forma visível na EC2, porque o checklist do `entrega.md` cobra "Uso de LabRole/LabInstanceProfile".

### 5.5 IA e relatório
- **[EXIGÊNCIA DA PROVA]** Ao pedir infraestrutura à IA, dizer explicitamente que o ambiente é **AWS Academy Learner Lab** e que deve usar `LabRole`/`LabInstanceProfile` **sem criar IAM**.
  *Origem: PROVA › Dicas*
- **[CONFIRMADO PELAS AULAS]** Registrar os prompts, o output da IA, o que foi mudado e por quê, e onde a IA errou. Ser honesto.
  *Origem: `aula-02/TF.md` › 6 (`ia-analise.md`); `aula-07/TF.md` › Dicas*
- **[INFERÊNCIA]** O `HISTORICO_IA.md` deste projeto é a base de evidência para as questões **Q2** e **Q4** do relatório.

---

## 6. Critérios de entrega

### 6.1 Pull Request
- **[EXIGÊNCIA DA PROVA]** Passos:
  1. Fork do repositório da disciplina.
  2. Criar `entregas/provaPrimeiroBi/SEU-RA/`.
  3. Adicionar **apenas** `entrega.md`.
  4. Commit e push no fork.
  5. Abrir o PR para o repositório original.

  *Origem: PROVA › "Como Entregar via Pull Request"*
- **[EXIGÊNCIA DA PROVA]** O `entrega.md` segue o modelo:
  - Aluno, RA, Data (da prova), Ferramenta de IA
  - URL `https://github.com/SEU-USUARIO/prova-primeiro-bimestre-devops`
  - Checklist de Evidências (13 itens)
  - seção Evidências com os outputs colados

  *Origem: PROVA › "Modelo do arquivo entrega.md"*
- **[EXIGÊNCIA DA PROVA]** **Um único PR por aluno.** Um segundo PR do mesmo RA é desconsiderado automaticamente.
  *Origem: PROVA › Regras 8*
- **[EXIGÊNCIA DA PROVA]** **Imutável após o envio:** nenhum commit no PR depois de aberto.
  *Origem: PROVA › Regras 9*
- **[EXIGÊNCIA DA PROVA]** O PR é aberto **somente no dia da prova, presencialmente**. PRs anteriores são desconsiderados.
  *Origem: PROVA › Regras 10*
- **[INFERÊNCIA]** Título do PR: **`[Prova Primeiro Bimestre] RA: NNNN - Nome Completo`**. É assim que o corretor identifica a prova e o RA.
  *Origem: BOT › `main()`; WF › warning do step "Regras de integridade da Prova"*
- **[INFERÊNCIA]** O link no `entrega.md` precisa ter exatamente `github.com/<usuario>/prova-primeiro-bimestre-devops`.
  *Origem: BOT › `extract_portfolio()`*
- **[INFERÊNCIA]** O código final precisa estar na **`main`**, porque o corretor lê a branch padrão.
  *Origem: BOT › `precheck_prova()`*

### 6.2 Pesos

**[EXIGÊNCIA DA PROVA]** *Origem: PROVA › "Critérios de Avaliação"*

| Componente | Peso |
|---|---|
| Git + Docker — histórico limpo, Conventional Commits, Dockerfile funcional | 15% |
| Docker Compose — API + PostgreSQL, volume, rede, healthcheck | 10% |
| Terraform + Módulos + Remote State — modularização, composição, VPC/SG/EC2/RDS, S3+DynamoDB, LabRole | 25% |
| Uso de IA como copiloto — uso documentado e crítico | 10% |
| Relatório Q1 / Q2 / Q3 / Q4 | 10% cada |

- **[INFERÊNCIA]** A nota do corretor automático (0 a 10) é **preliminar**. O professor confere, incluindo a execução no AWS Academy.
  *Origem: `README.md` raiz › "Como os PRs são avaliados"; BOT › modo prova*

---

## 7. Restrições

- **[EXIGÊNCIA DA PROVA]** Prova **individual**; **não copiar** a solução de colegas.
  *Origem: PROVA › Regras 1 e 4*
- **[EXIGÊNCIA DA PROVA]** O uso de qualquer LLM é permitido, desde que **informado** no relatório.
  *Origem: PROVA › Regras 2*
- **[EXIGÊNCIA DA PROVA]** Pode consultar documentação oficial e os materiais das aulas.
  *Origem: PROVA › Regras 3*
- **[EXIGÊNCIA DA PROVA]** Somente AWS Academy Learner Lab, região **`us-east-1`**, credenciais temporárias.
  *Origem: PROVA › Ambiente AWS; Regras 5*
- **[EXIGÊNCIA DA PROVA]** **NÃO criar IAM users/groups/roles.**
  *Origem: PROVA › Ambiente AWS; Parte 4; Regras 5*
- **[EXIGÊNCIA DA PROVA]** `terraform destroy` obrigatório depois das evidências.
  *Origem: PROVA › Regras 6*
- **[EXIGÊNCIA DA PROVA]** Nada de `.tfstate`, `.terraform/`, `.env` com senhas ou `*.pem` no repositório.
  *Origem: PROVA › Regras 7*
- **[CONFIRMADO PELAS AULAS]** Sem NAT Gateway e sem RDS Multi-AZ no Learner Lab.
  *Origem: `aula-04/README.md` › 7; `aula-05/README.md` › "Recursos no AWS Academy"*
- **[INFERÊNCIA]** Não alterar `.github/`, `provas/` ou `TF.md` no fork: o PR seria bloqueado.
  *Origem: WF › "Bloquear PR que altera arquivos sensiveis"*

---

## 8. Erros que podem fazer perder pontos

**NUNCA**
- NUNCA versionar `*.tfstate`, `.terraform/`, `.env`, `node_modules/`, `*.pem` — **[EXIGÊNCIA DA PROVA]** *(Regras 7; Parte 1)*
- NUNCA versionar `terraform.tfvars` com senha, nem `aws-creds.sh` — **[CONFIRMADO PELAS AULAS]** *(`aula-04/laboratorio-parte1.md` › 1.4; `aula-05/laboratorio-parte1.md` › 1.4)*
- NUNCA criar recursos `aws_iam_*` (role, user, group, instance profile) — **[EXIGÊNCIA DA PROVA]** *(Regras 5)*
- NUNCA guardar as reservas em memória — **[EXIGÊNCIA DA PROVA]** *(rotas › "Importante")*
- NUNCA abrir o PR antes do dia, abrir um segundo PR ou fazer push depois de abrir — **[EXIGÊNCIA DA PROVA]** *(Regras 8–10)*
- NUNCA liberar a porta 5432 do RDS para CIDR/internet; somente o SG da EC2 — **[EXIGÊNCIA DA PROVA]** *(Parte 4)*
- NUNCA colocar senha real no `.env.example` — **[EXIGÊNCIA DA PROVA]** *(Parte 3)*
- NUNCA copiar repositórios de colegas (há PRs de prova públicos) — **[EXIGÊNCIA DA PROVA]** *(Regras 4)*

**SEMPRE**
- SEMPRE criar o backend (S3 + DynamoDB) **antes** de configurar `backend "s3"` — **[EXIGÊNCIA DA PROVA]** *(Dicas)*
- SEMPRE rodar `terraform validate` e `plan` sem erros antes do `apply` — **[EXIGÊNCIA DA PROVA]** *(checklist do `entrega.md`)*
- SEMPRE executar `terraform destroy`, inclusive no backend — **[EXIGÊNCIA DA PROVA]** (destroy) / **[CONFIRMADO PELAS AULAS]** (backend) *(Regras 6; `aula-05/laboratorio-parte2.md` › Parte 7)*
- SEMPRE informar a IA usada no início do `relatorio.md` — **[EXIGÊNCIA DA PROVA]** *(Relatório)*
- SEMPRE dizer à IA que o ambiente é Learner Lab, sem IAM, com `LabRole`/`LabInstanceProfile` — **[EXIGÊNCIA DA PROVA]** *(Dicas)*
- SEMPRE testar tudo antes do dia; no dia, só o `entrega.md` e o PR — **[EXIGÊNCIA DA PROVA]** *(Dicas)*
- SEMPRE rodar `docker compose config` antes de subir o compose — **[CONFIRMADO PELAS AULAS]** *(`aula-02/TF.md` › Dicas)*

**ATENÇÃO**
- ATENÇÃO: um `ExpiredToken` exige reiniciar o lab e atualizar as credenciais — **[EXIGÊNCIA DA PROVA]** *(Dicas)*
- ATENÇÃO: o RDS leva 5–10 minutos para ficar pronto; o user_data, 2–3 minutos — **[CONFIRMADO PELAS AULAS]** *(`aula-05/laboratorio-parte1.md` › 5.1; `aula-04/laboratorio-parte2.md` › 4.2)*
- ATENÇÃO: o DB Subnet Group precisa de subnets em **AZs diferentes** — **[CONFIRMADO PELAS AULAS]** *(`aula-05/README.md` › 4)*
- ATENÇÃO: `docker compose down -v` apaga os dados; o `init.sql` só roda na primeira criação do volume — **[CONFIRMADO PELAS AULAS]** *(`aula-02/laboratorio-parte1.md` › 4.5–4.6)*
- ATENÇÃO: um lock preso no state se resolve com `terraform force-unlock <ID>` — **[CONFIRMADO PELAS AULAS]** *(`aula-05/laboratorio-parte2.md` › Troubleshooting)*
- ATENÇÃO: um relatório com menos de 10 linhas por questão perde nota; texto pesa 40% + 10% (uso de IA) — **[EXIGÊNCIA DA PROVA]** *(Critérios)*

---

## 9. Pegadinhas

1. **[INFERÊNCIA]** O **título do PR** não aparece no enunciado, só na automação: `[Prova Primeiro Bimestre] RA: NNNN - Nome`. *(BOT/WF)*
2. **[EXIGÊNCIA DA PROVA]** O cabeçalho diz "Enviada 1 semana antes", mas o PR **só pode ser aberto no dia**. O que sai uma semana antes é o enunciado. *(PROVA › cabeçalho × Regras 10)*
3. **[EXIGÊNCIA DA PROVA]** "Adicione **apenas** o arquivo `entrega.md`". **[INFERÊNCIA]** Por isso, as evidências entram coladas como texto e os screenshots ficam em `evidencias/` no repositório do projeto. *(PROVA › "Como Entregar")*
4. **[INFERÊNCIA]** Um fork desatualizado, ou com commits de entregas antigas, pode levar arquivos extras para o PR. Criar a branch da prova a partir da `main` atualizada do repositório original.
5. **[EXIGÊNCIA DA PROVA]** O SG do RDS deve aceitar **só o SG da EC2**. O código das aulas 05 e 06 libera o CIDR da VPC e **não serve** do jeito que está. *(Parte 4 × `aula-05/aula-05-rds/rds.tf`, `aula-06/laboratorio-parte1.md` › 4.2)*
6. **[EXIGÊNCIA DA PROVA]** Os TFs das aulas 03 e 04 criavam IAM role. Na prova isso é **proibido**. *(Regras 5 × `aula-03/TF.md`, `aula-04/TF.md` › 6)*
7. **[EXIGÊNCIA DA PROVA]** As APIs dos labs 04 e 07 usavam memória. Na prova, os dados vão para o Postgres, local e RDS.
8. **[INFERÊNCIA]** A aula 07 também tem `/reservas`, mas de salas (sala, funcionário, horário). A prova usa `id`, `cliente`, `data`, `status`. *(`aula-07/TF.md` × PROVA)*
9. **[EXIGÊNCIA DA PROVA]** O SG da EC2 deve liberar **22 e 3000**. O lab 06 liberava a porta 80. *(Parte 4 × `aula-06/laboratorio-parte1.md` › 4.2)*
10. **[INFERÊNCIA]** O `/health` é "usado pelo healthcheck do Compose": colocar healthcheck também na API, não só no banco.
11. **[INFERÊNCIA]** O `init.sql` não cria a tabela no RDS.
12. **[INFERÊNCIA]** O SSL obrigatório do RDS PostgreSQL 15 derruba o driver `pg` se não estiver configurado.
13. **[INFERÊNCIA]** Usar `endpoint` como host inclui `:5432` e quebra a conexão; usar `address`. *(`aula-05/aula-05-rds/outputs.tf`)*
14. **[EXIGÊNCIA DA PROVA]** "RDS **provisionado e funcional**": um `plan` só não basta. O CRUD na nuvem precisa gravar no RDS.
15. **[INFERÊNCIA]** O corretor lê só 6 arquivos e só na `main`. Código esquecido na feature branch, ou composição escondida fora de `infra/main.tf`, não aparece para ele.
16. **[INFERÊNCIA]** Um merge fast-forward não deixa merge commit. Publicar a feature branch (padrão de `aula-01/TF.md`) e/ou usar `git merge --no-ff`.
17. **[EXIGÊNCIA DA PROVA]** Os nomes dos módulos são exatos: `vpc`, `security-group` (com hífen), `ec2`, `rds`.
18. **[CONFIRMADO PELAS AULAS]** Destruir só `infra/` deixa o S3 e o DynamoDB vivos. Um bucket versionado precisa ser esvaziado antes, ou usar `force_destroy = true` como no lab. *(`aula-05/aula-05-backend/s3.tf`)*
19. **[INFERÊNCIA]** O `.gitignore` também precisa cobrir o state local de `infra/backend/` e o `infra/.terraform/`.
20. **[INFERÊNCIA]** `app-technova/`, citado nas aulas, **não existe** no repositório. Não há API de referência para copiar.
21. **[INFERÊNCIA — constatado na execução em 2026-09-30]** O Learner Lab tem uma **SCP que nega `s3:GetBucketObjectLockConfiguration`**. O provider AWS (v5.100.0) faz essa leitura ao criar/ler qualquer `resource "aws_s3_bucket"` → `AccessDenied ... explicit deny in a service control policy`. Solução adotada: bucket criado/removido via AWS CLI; o Terraform gerencia `aws_s3_bucket_versioning`, `..._server_side_encryption_configuration` e `..._public_access_block` (leituras permitidas). O professor admite criar o backend manualmente (`aula-06/laboratorio-parte2.md` › 5.1). *(Detalhes: HISTORICO_IA.md, Interações 20–22)*

---

## 10. Checklist final da prova

### Repositório / Git
- [ ] Repositório `prova-primeiro-bimestre-devops` existe, **público**, com nome exato
- [ ] `README.md` na raiz com nome, RA e descrição
- [ ] `.gitignore` com `node_modules`, `.env`, `.terraform`, `*.tfstate`, `*.pem` (+ `*.tfvars`, `aws-creds.sh`)
- [ ] `git ls-files` sem `.env`, `node_modules/`, `*.tfstate*`, `.terraform/`, `*.pem`, `terraform.tfvars` — **comando testado**
- [ ] ≥ 6 commits em Conventional Commits (`git log --oneline`) — **comando testado**
- [ ] Feature branch publicada + merge na `main` (`git log --graph --all`) — **comando testado**
- [ ] Código final na `main`

### API
- [ ] `app/src/`, `app/package.json`, `app/Dockerfile`, `app/.dockerignore` existem
- [ ] POST com validação (erro em campo faltando) — **testado com curl**
- [ ] GET lista — **testado**
- [ ] GET `/:id` retorna 200 / **404** — **testado**
- [ ] PUT — **testado**
- [ ] DELETE — **testado**
- [ ] `/health` — **testado**
- [ ] Dados persistem após `compose down` + `up` (não está em memória) — **testado**

### Docker / Compose
- [ ] `docker build` sem erro → `evidencias/docker-build.txt`
- [ ] Container responde na porta 3000 — **testado**
- [ ] Dockerfile multi-stage + usuário não-root (recomendado)
- [ ] `docker compose config` sem erro — **testado**
- [ ] `docker compose up -d --build` sobe API + Postgres com um comando — **testado**
- [ ] Volume nomeado, rede bridge customizada, healthcheck no banco, `depends_on` com condição
- [ ] `docker compose ps` mostra healthy → `evidencias/compose-ps.txt`
- [ ] `.env.example` sem senha real; `.env` ignorado

### Terraform / AWS
- [ ] `infra/{main,variables,outputs,providers}.tf` existem
- [ ] `infra/modules/{vpc,security-group,ec2,rds}/` existem, cada um com `main.tf`, `variables.tf`, `outputs.tf`
- [ ] `infra/backend/` cria S3 (versionamento + encriptação) + DynamoDB (`LockID`) — **apply testado**
- [ ] `providers.tf` com `backend "s3"` (`encrypt = true`, `dynamodb_table`) e `us-east-1`
- [ ] Composição de módulos visível em `infra/main.tf`
- [ ] VPC com públicas + privadas em 2 AZs
- [ ] SG EC2 22/3000; SG RDS 5432 **só do SG da EC2**
- [ ] EC2 t2.micro, subnet pública, `LabInstanceProfile`
- [ ] RDS db.t3.micro, `publicly_accessible = false`, `storage_encrypted = true`, `db_subnet_group_name` nas privadas
- [ ] Nenhum `aws_iam_*` no código (`grep -r "aws_iam" infra/`) — **comando testado**
- [ ] Tags em todos os recursos
- [ ] Outputs: IP da EC2, endpoint do RDS, URL da API
- [ ] `terraform validate` sem erro — **testado**
- [ ] `terraform plan` sem erro → `evidencias/terraform-plan.txt`
- [ ] `apply` no Learner Lab; CRUD na EC2 gravando no RDS — **testado com curl**
- [ ] State no S3 comprovado (`aws s3 ls`) — **testado**
- [ ] `terraform destroy` em `infra/` e em `infra/backend/` — **executado**

### IA / Relatório
- [ ] `relatorio.md` na raiz, com a IA usada informada no início
- [ ] Q1–Q4 dissertativas, ≥ 10 linhas cada
- [ ] Q2 com prompts reais, acertos e correções (base: `HISTORICO_IA.md`)
- [ ] Q4 com o checklist aplicado antes do `apply`

### PR (no dia da prova)
- [ ] Hoje é o dia da prova
- [ ] Branch criada a partir da `main` atualizada do repositório original
- [ ] Diff do PR contém **só** `entregas/provaPrimeiroBi/SEU-RA/entrega.md`
- [ ] `entrega.md` no modelo (Aluno, RA, Data, IA, URL, checklist, evidências)
- [ ] Título `[Prova Primeiro Bimestre] RA: NNNN - Nome Completo`
- [ ] Nenhum outro PR de prova com o meu RA
- [ ] Depois de abrir: **nenhum push** na branch

---

## Histórico de atualizações deste arquivo

| Data | Alteração |
|---|---|
| 2026-09-30 | v1 — criado com regras gerais das aulas + regras da prova (etiquetas EXIGÊNCIA DO PROFESSOR/PADRÃO/INFERÊNCIA) |
| 2026-09-30 | v2 — reescrito a pedido do aluno: **somente regras da prova**, etiquetas [EXIGÊNCIA DA PROVA] / [CONFIRMADO PELAS AULAS] / [INFERÊNCIA]; seção de CI/CD e regras gerais removidas |
| 2026-10-01 | Pegadinha 21 — SCP do Learner Lab bloqueia `aws_s3_bucket` (Object Lock); solução adotada |
