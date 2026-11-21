-- ============================================================
-- CONSULTA 1 (JOIN): itens de cada pedido com cliente e produto
-- Uso real: tela "Meus pedidos" (GET /api/pedidos?email=...)
-- ============================================================
SELECT p.id AS pedido, p.status, p.criado_em, c.nome AS cliente,
       pr.nome AS produto, i.quantidade, i.preco_unitario
FROM pedidos p
JOIN clientes c       ON c.id = p.cliente_id
JOIN itens_pedido i   ON i.pedido_id = p.id
JOIN produtos pr      ON pr.id = i.produto_id
WHERE c.email = 'maria@exemplo.com'
ORDER BY p.criado_em DESC;

-- ============================================================
-- CONSULTA 2 (agregação): faturamento e unidades por produto
-- Uso real: saber quais perfumes mais vendem (pedidos não cancelados)
-- ============================================================
SELECT pr.nome, SUM(i.quantidade) AS unidades, SUM(i.quantidade * i.preco_unitario) AS faturamento
FROM itens_pedido i
JOIN pedidos p   ON p.id = i.pedido_id
JOIN produtos pr ON pr.id = i.produto_id
WHERE p.status <> 'cancelado'
GROUP BY pr.nome
ORDER BY faturamento DESC;

-- ============================================================
-- CONSULTA 3 (filtro + ordenação): produtos com estoque baixo
-- Uso real: aviso de reposição para a equipe
-- ============================================================
SELECT nome, tipo, estoque
FROM produtos
WHERE ativo AND estoque < 10
ORDER BY estoque ASC, nome;

-- ============================================================
-- CONSULTA 4 (JOIN + GROUP BY + HAVING): clientes que mais compraram
-- Uso real: identificar clientes frequentes (pedidos não cancelados)
-- ============================================================
SELECT c.nome, c.email, COUNT(DISTINCT p.id) AS pedidos, SUM(i.quantidade * i.preco_unitario) AS total_gasto
FROM clientes c
JOIN pedidos p       ON p.cliente_id = c.id
JOIN itens_pedido i  ON i.pedido_id = p.id
WHERE p.status <> 'cancelado'
GROUP BY c.id, c.nome, c.email
HAVING SUM(i.quantidade * i.preco_unitario) > 100
ORDER BY total_gasto DESC;

-- ============================================================
-- CONSULTA 5 (LEFT JOIN + COUNT): interesses (contatos) por produto
-- Uso real: saber qual perfume gera mais contato, mesmo os sem nenhum
-- ============================================================
SELECT pr.nome, COUNT(ct.id) AS contatos
FROM produtos pr
LEFT JOIN contatos ct ON ct.produto_id = pr.id
GROUP BY pr.id, pr.nome
ORDER BY contatos DESC, pr.nome;

-- ============================================================
-- CONSULTA 6 (agregação): quantidade e valor de pedidos por status
-- Uso real: painel de acompanhamento de vendas
-- ============================================================
SELECT status, COUNT(*) AS pedidos, COALESCE(SUM(total), 0) AS valor_total
FROM pedidos
GROUP BY status
ORDER BY pedidos DESC;

-- ============================================================
-- CONSULTA 7 (LEFT JOIN + IS NULL): produtos que ainda não foram vendidos
-- Uso real: sugerir promoção/divulgação de perfumes sem saída
-- ============================================================
SELECT pr.nome, pr.estoque
FROM produtos pr
LEFT JOIN itens_pedido i ON i.produto_id = pr.id
WHERE i.pedido_id IS NULL;

-- ============================================================
-- CONSULTA 8 (subconsulta): pedidos acima do valor médio
-- Uso real: destacar compras de maior valor
-- ============================================================
SELECT p.id, c.nome, p.total, p.status
FROM pedidos p
JOIN clientes c ON c.id = p.cliente_id
WHERE p.total > (SELECT AVG(total) FROM pedidos WHERE status <> 'cancelado')
ORDER BY p.total DESC;

-- ============================================================
-- CONSULTA 9 (JOIN): últimos contatos recebidos com cliente e produto
-- Uso real: GET /api/contatos (fila de atendimento da equipe)
-- ============================================================
SELECT ct.id, c.nome, c.email, pr.nome AS produto, ct.assunto, ct.criado_em
FROM contatos ct
JOIN clientes c         ON c.id = ct.cliente_id
LEFT JOIN produtos pr   ON pr.id = ct.produto_id
ORDER BY ct.criado_em DESC
LIMIT 10;

-- ============================================================
-- ÍNDICE: idx_pedidos_cliente_data (db/indice.sql)
-- Consulta frequente: pedidos de um cliente, mais recentes primeiro.
-- ANTES de criar o índice:
--   DROP INDEX IF EXISTS idx_pedidos_cliente_data;
--   EXPLAIN ANALYZE SELECT * FROM pedidos WHERE cliente_id = 1 ORDER BY criado_em DESC;
-- DEPOIS:
--   CREATE INDEX idx_pedidos_cliente_data ON pedidos (cliente_id, criado_em DESC);
--   EXPLAIN ANALYZE SELECT * FROM pedidos WHERE cliente_id = 1 ORDER BY criado_em DESC;
-- Com poucas linhas o PostgreSQL pode continuar escolhendo Seq Scan (é mais barato).
-- Para demonstrar o plano com índice, use: SET enable_seqscan = off;
-- Esperado: "Seq Scan + Sort" passa a "Index Scan" sem etapa de Sort.
-- (Cole os resultados reais e prints no relatório.)
-- ============================================================
