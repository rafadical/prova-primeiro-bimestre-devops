const express = require('express');
const { pool, STATUS_VALIDOS } = require('../db');

const router = express.Router();

// Valida os campos obrigatórios: cliente, data (YYYY-MM-DD) e status
function validarReserva(corpo) {
  const erros = [];
  const { cliente, data, status } = corpo || {};

  if (typeof cliente !== 'string' || cliente.trim() === '') {
    erros.push('cliente é obrigatório');
  } else if (cliente.trim().length > 100) {
    erros.push('cliente deve ter no máximo 100 caracteres');
  }

  if (typeof data !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(data)) {
    erros.push('data é obrigatória no formato YYYY-MM-DD');
  } else {
    const d = new Date(`${data}T00:00:00Z`);
    if (Number.isNaN(d.getTime()) || d.toISOString().slice(0, 10) !== data) {
      erros.push('data inválida');
    }
  }

  if (!STATUS_VALIDOS.includes(status)) {
    erros.push(`status é obrigatório e deve ser um de: ${STATUS_VALIDOS.join(', ')}`);
  }

  return erros;
}

// Aceita apenas ids inteiros positivos; qualquer outro valor é tratado como inexistente
function idValido(id) {
  return /^\d+$/.test(id) && Number(id) <= 2147483647;
}

// POST /reservas — cria uma reserva
router.post('/', async (req, res, next) => {
  try {
    const erros = validarReserva(req.body);
    if (erros.length) return res.status(400).json({ erros });

    const { cliente, data, status } = req.body;
    const { rows } = await pool.query(
      'INSERT INTO reservas (cliente, data, status) VALUES ($1, $2, $3) RETURNING *',
      [cliente.trim(), data, status]
    );
    res.status(201).json(rows[0]);
  } catch (erro) {
    next(erro);
  }
});

// GET /reservas — lista todas
router.get('/', async (req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT * FROM reservas ORDER BY id');
    res.json(rows);
  } catch (erro) {
    next(erro);
  }
});

// GET /reservas/:id — busca por id (404 se não existir)
router.get('/:id', async (req, res, next) => {
  try {
    if (!idValido(req.params.id)) return res.status(404).json({ erro: 'Reserva não encontrada' });

    const { rows } = await pool.query('SELECT * FROM reservas WHERE id = $1', [req.params.id]);
    if (!rows.length) return res.status(404).json({ erro: 'Reserva não encontrada' });
    res.json(rows[0]);
  } catch (erro) {
    next(erro);
  }
});

// PUT /reservas/:id — atualiza uma reserva existente
router.put('/:id', async (req, res, next) => {
  try {
    if (!idValido(req.params.id)) return res.status(404).json({ erro: 'Reserva não encontrada' });

    const erros = validarReserva(req.body);
    if (erros.length) return res.status(400).json({ erros });

    const { cliente, data, status } = req.body;
    const { rows } = await pool.query(
      'UPDATE reservas SET cliente = $1, data = $2, status = $3 WHERE id = $4 RETURNING *',
      [cliente.trim(), data, status, req.params.id]
    );
    if (!rows.length) return res.status(404).json({ erro: 'Reserva não encontrada' });
    res.json(rows[0]);
  } catch (erro) {
    next(erro);
  }
});

// DELETE /reservas/:id — remove uma reserva (retorna a reserva removida)
router.delete('/:id', async (req, res, next) => {
  try {
    if (!idValido(req.params.id)) return res.status(404).json({ erro: 'Reserva não encontrada' });

    const { rows } = await pool.query('DELETE FROM reservas WHERE id = $1 RETURNING *', [req.params.id]);
    if (!rows.length) return res.status(404).json({ erro: 'Reserva não encontrada' });
    res.json(rows[0]);
  } catch (erro) {
    next(erro);
  }
});

module.exports = router;
