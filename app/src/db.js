const { Pool, types } = require('pg');

// Retorna colunas DATE como texto 'YYYY-MM-DD' (evita conversão de fuso horário)
types.setTypeParser(1082, (valor) => valor);

// Configuração via variáveis de ambiente (local: Docker Compose / nuvem: RDS)
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 5432,
  database: process.env.DB_NAME || 'reservas',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  // O RDS PostgreSQL 15 exige conexão SSL por padrão; no Compose fica desligado
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
});

// Sem este handler, a queda do banco derruba o processo inteiro da API
pool.on('error', (erro) => {
  console.error('Erro em conexão ociosa com o banco:', erro.message);
});

const STATUS_VALIDOS = ['pendente', 'confirmada', 'cancelada'];

// Cria a tabela se não existir (o init.sql do Compose não roda no RDS)
async function iniciarBanco(tentativas = 10, esperaMs = 3000) {
  for (let i = 1; i <= tentativas; i++) {
    try {
      await pool.query(`
        CREATE TABLE IF NOT EXISTS reservas (
          id      SERIAL PRIMARY KEY,
          cliente VARCHAR(100) NOT NULL,
          data    DATE         NOT NULL,
          status  VARCHAR(20)  NOT NULL
            CHECK (status IN ('pendente', 'confirmada', 'cancelada'))
        )
      `);
      return;
    } catch (erro) {
      console.error(`Banco indisponível (tentativa ${i}/${tentativas}): ${erro.message}`);
      if (i === tentativas) throw erro;
      await new Promise((resolve) => setTimeout(resolve, esperaMs));
    }
  }
}

module.exports = { pool, iniciarBanco, STATUS_VALIDOS };
