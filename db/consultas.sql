-- Consultas do projeto Alma & Aroma (PostgreSQL / Neon)
-- Como usar: abra o SQL Editor do Neon, cole UMA consulta por vez e clique em Run.
-- "Quem executa": o site (via API) ou você, à mão, para mostrar no relatório/seminário.

-- ============================================================
-- CONSULTA 1 (filtro + ordenação): perfumes disponíveis, do mais barato ao mais caro
-- Quem executa: o site usa uma versão parecida (GET /api/produtos monta os cards)
-- ============================================================
SELECT nome, tipo, preco, estoque
FROM produtos
WHERE ativo
ORDER BY preco;

-- ============================================================
-- CONSULTA 2 (filtro + ordenação): produtos com estoque baixo
-- Quem executa: você, no Neon (aviso de reposição)
-- Como testar: vem vazia no início. Baixe um estoque e rode de novo:
--   UPDATE produtos SET estoque = 5 WHERE nome = 'Bosque Sereno';
-- (o site também baixa o estoque a cada pedido feito)
-- ============================================================
SELECT nome, estoque
FROM produtos
WHERE estoque < 10
ORDER BY estoque;

-- ============================================================
-- CONSULTA 3 (JOIN): pedidos de um cliente, do mais novo para o mais antigo
-- Quem executa: o site usa uma versão parecida (janela "Meus pedidos"). É a consulta que o índice acelera.
-- Troque o e-mail para ver outro cliente.
-- ============================================================
SELECT p.id AS pedido, p.status, p.total, p.criado_em
FROM pedidos p
JOIN clientes c ON c.id = p.cliente_id
WHERE c.email = 'maria@exemplo.com'
ORDER BY p.criado_em DESC;

-- ============================================================
-- CONSULTA 4 (JOIN): itens de um pedido, com o nome do perfume
-- Quem executa: o site usa uma versão parecida (itens em "Meus pedidos"); aqui, só o pedido 1
-- ============================================================
SELECT pr.nome AS perfume, i.quantidade, i.preco_unitario
FROM itens_pedido i
JOIN produtos pr ON pr.id = i.produto_id
WHERE i.pedido_id = 1;

-- ============================================================
-- CONSULTA 5 (agregação COUNT): quantos pedidos existem em cada status
-- Quem executa: você, no Neon (painel de acompanhamento)
-- ============================================================
SELECT status, COUNT(*) AS pedidos
FROM pedidos
GROUP BY status;

-- ============================================================
-- CONSULTA 6 (JOIN + agregação SUM): unidades pedidas de cada perfume
-- Quem executa: você, no Neon (quais perfumes saem mais; inclui pedidos cancelados)
-- ============================================================
SELECT pr.nome, SUM(i.quantidade) AS unidades
FROM itens_pedido i
JOIN produtos pr ON pr.id = i.produto_id
GROUP BY pr.nome
ORDER BY unidades DESC;

-- ============================================================
-- ÍNDICE: idx_pedidos_cliente_data (db/indice.sql)
-- Consulta frequente: a consulta 3 (pedidos de um cliente, mais recentes primeiro).
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
