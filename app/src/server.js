const express = require('express');
const { pool, iniciarBanco } = require('./db');
const reservasRouter = require('./routes/reservas');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// GET /health — health check (usado pelo healthcheck do Docker Compose)
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'healthy', banco: 'conectado', uptime: process.uptime() });
  } catch (erro) {
    res.status(503).json({ status: 'unhealthy', banco: 'indisponível' });
  }
});

app.use('/reservas', reservasRouter);

// Rota inexistente
app.use((req, res) => {
  res.status(404).json({ erro: 'Rota não encontrada' });
});

// Erros (JSON malformado ou falha no banco)
app.use((erro, req, res, next) => {
  if (erro.type === 'entity.parse.failed') {
    return res.status(400).json({ erro: 'JSON inválido' });
  }
  console.error(erro);
  res.status(500).json({ erro: 'Erro interno do servidor' });
});

iniciarBanco()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`API de Reservas rodando na porta ${PORT}`);
    });
  })
  .catch((erro) => {
    console.error('Não foi possível conectar ao banco de dados:', erro.message);
    process.exit(1);
  });
