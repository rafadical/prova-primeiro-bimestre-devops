# Relatório do Processo — Prova do 1º Bimestre (DevOps)

**Aluno:** Rafael Nogueira Maruca  
**RA:** 6322006  
**Ferramenta de IA utilizada:** **Claude Code** (modelo Claude Opus 5.5, da Anthropic), usado como copiloto no terminal e no editor. Não utilizei o Kiro.

**Como a IA foi usada, de forma transparente:** o Claude Code não apenas sugeriu código — ele **criou os arquivos e executou os comandos** (Git, Docker, Terraform e AWS CLI), **inclusive os commits e o push** deste repositório, sempre depois da minha autorização para cada etapa. O meu papel foi definir as regras do trabalho, tomar as decisões que a prova não define, aprovar ou rejeitar cada etapa, conferir os resultados e executar parte das evidências (os prints do terminal e do navegador foram feitos por mim).

Durante toda a prova mantive dois arquivos de apoio, que estão na pasta [`docs/`](docs/) deste repositório: o `REGRAS.md`, com as exigências da prova separadas entre o que está explícito no enunciado, o que as aulas confirmam e o que era inferência; e o `HISTORICO_IA.md`, com cada interação com a IA (contexto, prompt, sugestão, minha decisão, o que foi implementado, como validei e o resultado), incluindo os erros que a IA cometeu. As respostas abaixo se baseiam nesse histórico.

---

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

Antes de escrever qualquer código, pedi à IA para ler o enunciado da prova e todo o material das aulas 01 a 07 e dividir a prova em 15 etapas pequenas, em ordem de execução.

Essa divisão segue a própria dica do professor ("comece pelo Git e pela aplicação; containerize; suba local com Compose; só então vá para a AWS") e o conceito de decomposição da Aula 07: cada etapa tinha objetivo, arquivos, se precisava ou não de AWS e como validar.

Só avançávamos para a etapa seguinte depois de validar a atual.

A **Aula 01** apareceu logo no começo: criei o repositório `prova-primeiro-bimestre-devops` com `git init -b main`, `.gitignore` e README, e usei Conventional Commits e feature branches durante todo o projeto (`feature/api-reservas`, `feature/infra-terraform`, `feature/documentacao`), integradas com `git merge --no-ff` para o merge ficar visível no histórico.

Também da Aula 01 veio o Dockerfile: mantive o padrão `node:20-alpine` com o `package*.json` copiado antes do código, e evoluí para multi-stage com usuário não-root, como a prova recomenda.

A **Aula 02** apareceu no `docker-compose.yml` (API + PostgreSQL 15, volume nomeado, rede bridge customizada, healthcheck com `pg_isready`, `depends_on` com `service_healthy`, `.env.example` sem senha real) e no uso da IA como copiloto com checklist de validação (`docker compose config` antes de subir).

As **Aulas 03 a 06** formaram a infraestrutura. Da Aula 03 vieram o fluxo `init → validate → plan → apply → destroy`, os providers e as tags; o IAM da Aula 03 serviu como conceito, porque no Learner Lab não é permitido criar roles.

Da Aula 04 vieram a VPC com subnets públicas e privadas, o Internet Gateway, os Security Groups, a AMI via data source, o key pair e o user data.

Da Aula 05 vieram o RDS nas subnets privadas (DB Subnet Group em 2 AZs) e o remote state com S3 e DynamoDB.

Da Aula 06 vieram os módulos `vpc`, `security-group`, `ec2` e `rds`, o `for_each` nas subnets e a composição (o output de um módulo alimentando o input do outro).

A ordem foi escolhida por dependência: primeiro a API funcionando localmente contra um PostgreSQL de verdade, depois a imagem, depois o Compose, e só então a nuvem, porque a EC2 clona o repositório público e constrói a mesma imagem já testada.

Na AWS, o backend veio antes do projeto principal (o bucket precisa existir antes do `backend "s3"`), e o `terraform destroy` só foi executado depois de capturar todas as evidências.

A **Aula 07** atravessou o projeto inteiro: decompor, guiar a IA com contexto e regras, e validar cada parte antes de seguir.

---

## Questão 2 — O Processo com IA como Copiloto

Usei o **Claude Code**. Não usei o modo Spec do Kiro, mas apliquei a mesma ideia de Requisitos → Design → Tarefas: primeiro a IA analisou o enunciado e montou o `REGRAS.md` (o que é exigência, o que é padrão das aulas e o que é inferência); depois dividimos a prova em 15 etapas; e só então implementamos, uma etapa por vez, com a minha aprovação antes de seguir.

Os prompts principais foram, em resumo: "analise todo o conteúdo das aulas 1 a 7 e principalmente a prova, sem inventar requisitos e diferenciando exigência, padrão e inferência"; "divida toda a prova em etapas pequenas e me avise exatamente quando chegar a etapa que precisa da AWS"; e, depois que a IA cometeu alguns erros, "antes de qualquer comando faça uma pré-validação (estado do projeto, arquivos, containers, portas, shell) e não gere evidência antes de confirmar que o teste está correto". Este último prompt mudou a qualidade do trabalho dali em diante.

A IA gerou bem o código da API (CRUD com validação e 404), o Dockerfile multi-stage, o `docker-compose.yml`, os quatro módulos Terraform e a composição em `infra/main.tf`. Também acertou em pontos que as aulas não cobrem e que eu provavelmente esqueceria: a API criar a tabela sozinha (o `init.sql` do Compose não roda no RDS), o SSL obrigatório no RDS PostgreSQL 15, usar o atributo `address` (sem a porta) do RDS como host e estender o módulo de Security Group para aceitar um SG de origem.

O que precisou ser corrigido, e que eu decidi registrar com honestidade:
- A primeira versão da API caía inteira quando o banco ficava fora do ar. O teste com o banco parado revelou isso, e foi corrigido.
- Uma evidência de build registrou um código de saída falso.
- O primeiro teste do container foi respondido por outro container meu, da Aula 02, que ocupava a porta 3000. Eu autorizei parar esse projeto para liberar a porta.
- Várias verificações usaram `grep`, `tail` ou `$?` de forma errada e geraram falsos positivos.
- Em um comando, a IA esqueceu de carregar as credenciais do Lab.

Todos os erros e fragilidades da IA estão registrados na tabela consolidada do histórico (`docs/HISTORICO_IA.md`), e nenhum teve impacto na infraestrutura entregue. Seis deles só apareceram em uma auditoria final que pedi à IA, agindo "como o professor": uma afirmação incorreta neste relatório, uma linha de evidência digitada em vez de capturada, um trecho de evidência resumido sem aviso, a persistência do Compose apenas afirmada, trechos editados no rascunho do `entrega.md` e uma captura sem o código HTTP do POST. Todos foram corrigidos antes da entrega.

Também tomei decisões que a IA não podia tomar sozinha: as regras de validação que a prova não define (campos obrigatórios, formato da data e uma lista fixa de status), usar SSE-S3 em vez de KMS no bucket e como contornar a restrição do Learner Lab no S3 (tirar o bucket do state em vez de testar outra versão do provider). Já a forma de rodar a API na EC2 (Docker em vez de Node direto) foi uma recomendação da IA que **ela aplicou sem que eu tivesse escolhido explicitamente** — eu havia pedido para seguir até a etapa da AWS e não respondi a essa pergunta. Registrei isso como uma falha do processo: uma decisão de arquitetura deveria ter esperado a minha resposta. Comparando com fazer manualmente, a IA economizou muito tempo em código repetitivo e em detalhes de sintaxe do Terraform. Atrapalhou quando "afirmava" resultados a partir de verificações mal feitas. Por isso exigi as pré-validações e conferi cada resultado antes de aceitar.

---

## Questão 3 — Infraestrutura, Segurança e o Learner Lab

Provisionei uma VPC `10.0.0.0/16` em `us-east-1` com quatro subnets em duas AZs: duas públicas (10.0.1.0/24 e 10.0.2.0/24), associadas a uma route table com rota `0.0.0.0/0` para o Internet Gateway, e duas privadas (10.0.3.0/24 e 10.0.4.0/24), sem rota para a internet.

A EC2 t2.micro fica na subnet pública, roda a API em um container Docker na porta 3000 e tem um Security Group que libera apenas as portas 22 e 3000.

O RDS PostgreSQL 15 db.t3.micro fica nas subnets privadas, através de um DB Subnet Group que exige duas AZs. Ele tem `publicly_accessible = false`, `storage_encrypted = true`, e um Security Group que aceita a porta 5432 **somente a partir do Security Group da EC2**, sem nenhum CIDR. O diagrama está no `README.md`.

O RDS fica na subnet privada porque o banco não precisa e não deve ser alcançável pela internet: só a API conversa com ele. A EC2 fica na pública porque precisa receber as requisições dos clientes.

Na prática, confirmei pela EC2 com `psql` que o servidor do banco tinha o IP 10.0.3.250, dentro da subnet privada, e que os dados gravados pela API estavam lá.

Também confirmei pela AWS CLI que o RDS estava com "público = False" e "encriptado = True", e que a regra do SG tinha como origem o ID do SG da EC2.

Em vez de criar IAM próprio, que o Lab bloqueia, a instância usa o `LabInstanceProfile`, que já contém a `LabRole`.

No Terraform isso é só `iam_instance_profile = "LabInstanceProfile"` no módulo `ec2`, e o plan mostrou zero recursos `aws_iam_*`. A IA havia sido orientada desde o início com essa restrição, como o professor recomenda.

O Learner Lab exigiu vários ajustes em relação ao que foi ensinado:
- As credenciais são temporárias e incluem um Session Token. Usei o `aws-creds.sh` com `export` e `source`, como nas aulas, e esse arquivo fica fora do Git. Na primeira vez colei o bloco no formato INI que o Lab mostra, e ele não funcionaria com `source`; a IA verificou o formato sem exibir os valores e eu corrigi.
- Existia um `~/.aws/credentials` antigo e expirado, e as variáveis de ambiente tiveram prioridade sobre ele.
- A região é sempre `us-east-1`.
- O problema maior foi uma SCP do Lab que nega `s3:GetBucketObjectLockConfiguration`. O provider AWS faz essa leitura em qualquer `aws_s3_bucket`, então o apply do backend falhou depois de criar o bucket. Escolhi tirar o bucket do controle do Terraform com `terraform state rm`, sem apagá-lo, e manter no Terraform o versionamento, a encriptação, o bloqueio de acesso público e a tabela DynamoDB. O professor admite criar o backend manualmente (Aula 06, lab 2). No destroy, o bucket tinha 6 versões do state, o que comprova que o versionamento funcionou.

---

## Questão 4 — Validação e Responsabilidade

Antes de qualquer `terraform apply` em código gerado pela IA, apliquei este checklist:
- `terraform fmt -check` e `terraform validate` sem erros, inclusive com os módulos validados isoladamente.
- `grep` por `aws_iam` igual a zero.
- `terraform plan -out` e leitura do plano atributo por atributo: t2.micro, `LabInstanceProfile`, db.t3.micro, `publicly_accessible = false`, `storage_encrypted = true`, subnets em duas AZs, SG do RDS sem CIDR e com origem no SG da EC2, tags e outputs.
- Senha e `user_data` aparecendo como `(sensitive value)` e a senha ausente no texto do plano.
- Nomes de recursos que não colidissem com nada existente.
- O `apply` sempre do plano salvo, para executar exatamente o que eu tinha revisado.

O mesmo vale para o backend e para o destroy, que também passou por `plan -destroy` antes de ser executado.

Para validar que a infraestrutura estava correta e segura, não confiei só no "Apply complete":
- Testei o CRUD completo na URL da EC2.
- Consultei o RDS de dentro da EC2 com `psql` e SSL.
- Conferi pela AWS CLI a configuração do RDS, do Security Group, da EC2 e do bucket (versionamento Enabled, AES256, bloqueio público ativo).
- Conferi a tabela de lock.
- Só gerei os arquivos de evidência depois de confirmar que cada teste estava certo e vinha do serviço correto, e verifiquei que nenhuma senha ou credencial aparecia neles.
- No final, confirmei que nenhum recurso tinha sobrado na AWS.

Mesmo com essas validações, a auditoria final mostrou pontos que continuam frágeis e que eu prefiro declarar a esconder:
- A porta 22 ficou aberta para `0.0.0.0/0`. É o que o professor exigiu no TF da Aula 04 e usou no código da Aula 05, mas o TA da mesma aula recomenda liberar o SSH "apenas do seu IP". Em termos de menor privilégio, o ideal seria restringir ao meu IP com a variável `ssh_allowed_cidrs`, que já existe no código.
- A senha do RDS chega à EC2 pelo user data.
- A conexão SSL com o RDS não valida o certificado.
- A EC2 constrói a imagem a partir da `main` sem versão fixa.
- A criação do bucket do state via CLI está documentada, mas não foi executada.

Não alterei esses pontos depois do destroy, porque o código deixaria de corresponder ao que foi aplicado e evidenciado. Eles estão listados no README como limitações conhecidas.

Se eu tivesse aceitado o código da IA sem revisar, teria tido problemas reais. A API cairia com qualquer instabilidade do banco. Uma evidência mostraria um resultado que não aconteceu. Um teste teria "passado" respondido por outro projeto. E várias verificações automáticas da IA teriam me convencido de falhas que não existiam, ou de sucessos que não estavam comprovados. Na nuvem, um erro de Security Group ou de `publicly_accessible` poderia expor o banco à internet, e uma criação de role faria o apply falhar no Lab. Ou seja: a IA é rápida, mas quem responde pelo resultado sou eu.

A evolução Git → Docker → Terraform → Modules foi o que me permitiu usar a IA com responsabilidade. Como eu já tinha feito cada peça nas aulas, conseguia ler o que a IA gerava e perceber quando algo estava errado: um healthcheck faltando, uma porta errada, um recurso IAM proibido. O Git me deu histórico para revisar cada mudança. O Docker me deu um ambiente reproduzível para testar antes de ir para a nuvem. O Terraform com `plan` me deu um ponto de revisão antes de criar qualquer coisa. E os módulos dividiram a infraestrutura em partes pequenas, fáceis de validar, que é exatamente a decomposição da Aula 07.
