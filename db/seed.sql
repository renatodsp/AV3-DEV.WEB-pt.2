-- Dados fictícios de demonstração
INSERT INTO produtos (nome, tipo, descricao, preco, ml, estoque) VALUES
 ('Flor de Aurora', 'Floral',     'Uma fragrância delicada, inspirada na leveza e no frescor das flores.', 129.00, 50, 20),
 ('Bosque Sereno',  'Amadeirado', 'Notas envolventes para quem prefere aromas intensos e elegantes.',      149.00, 50, 15),
 ('Luz Cítrica',    'Cítrico',    'Uma combinação refrescante para um dia mais leve e cheio de energia.',  119.00, 50, 25);

INSERT INTO clientes (nome, email) VALUES
 ('Maria Exemplo', 'maria@exemplo.com'),
 ('João Teste',    'joao@exemplo.com');

INSERT INTO contatos (cliente_id, produto_id, assunto, mensagem) VALUES
 (1, 1, 'Interesse no perfume Flor de Aurora', 'Olá! Gostaria de saber mais sobre o perfume Flor de Aurora.');

INSERT INTO pedidos (cliente_id, status, total) VALUES
 (1, 'confirmado', 278.00),
 (2, 'pendente',   119.00);

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
 (1, 1, 1, 129.00),
 (1, 2, 1, 149.00),
 (2, 3, 1, 119.00);
