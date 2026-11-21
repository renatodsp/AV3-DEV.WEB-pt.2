-- Índice justificado pela consulta "meus pedidos" (filtro por cliente + ordenação por data)
CREATE INDEX IF NOT EXISTS idx_pedidos_cliente_data ON pedidos (cliente_id, criado_em DESC);
