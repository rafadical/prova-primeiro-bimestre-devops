# ==================================================
# Dockerfile - API de Reservas (TechNova)
# Multi-stage: instala dependências em um estágio e
# copia apenas o necessário para a imagem final.
# ==================================================

# ---------- Estágio 1: dependências de produção ----------
FROM node:20-alpine AS deps

WORKDIR /app

# Copia apenas os manifestos primeiro (cache de camadas:
# o npm ci só roda de novo se as dependências mudarem)
COPY package*.json ./

# Instala somente dependências de produção, conforme o package-lock.json
RUN npm ci --omit=dev

# ---------- Estágio 2: imagem final ----------
FROM node:20-alpine

ENV NODE_ENV=production

WORKDIR /app

# Dependências vindas do estágio anterior + código-fonte
COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./
COPY src ./src

# Executa como usuário não-root (o usuário "node" já existe na imagem oficial)
USER node

# Porta da API
EXPOSE 3000

CMD ["node", "src/server.js"]
