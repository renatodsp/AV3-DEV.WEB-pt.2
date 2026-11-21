-- Esquema do banco da Alma & Aroma (PostgreSQL / Neon)
-- Pode ser executado várias vezes: recria as tabelas do zero.

DROP TABLE IF EXISTS itens_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS contatos CASCADE;
DROP TABLE IF EXISTS produtos CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

CREATE TABLE clientes (
    id        SERIAL PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    email     VARCHAR(150) NOT NULL UNIQUE,
    criado_em TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE produtos (
    id        SERIAL PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL UNIQUE,
    tipo      VARCHAR(30)  NOT NULL,
    descricao TEXT         NOT NULL,
    preco     NUMERIC(10,2) NOT NULL CHECK (preco > 0),
    ml        INTEGER      NOT NULL CHECK (ml > 0),
    estoque   INTEGER      NOT NULL DEFAULT 0 CHECK (estoque >= 0),
    ativo     BOOLEAN      NOT NULL DEFAULT TRUE
);

-- Formulário "Fale com a gente" / "Tenho interesse"
CREATE TABLE contatos (
    id         SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
    produto_id INTEGER REFERENCES produtos(id) ON DELETE SET NULL,
    assunto    VARCHAR(150) NOT NULL,
    mensagem   TEXT NOT NULL,
    criado_em  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE pedidos (
    id         SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(id),
    status     VARCHAR(20) NOT NULL DEFAULT 'pendente'
               CHECK (status IN ('pendente', 'confirmado', 'cancelado')),
    total      NUMERIC(10,2) NOT NULL CHECK (total >= 0),
    criado_em  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE itens_pedido (
    pedido_id      INTEGER NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_id     INTEGER NOT NULL REFERENCES produtos(id),
    quantidade     INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario NUMERIC(10,2) NOT NULL CHECK (preco_unitario > 0),
    PRIMARY KEY (pedido_id, produto_id)
);

-- Índice adicional: a consulta "meus pedidos" filtra por cliente_id e
-- ordena por data. O PostgreSQL não cria índice automático em chave estrangeira.
-- (Veja db/consultas.sql para o EXPLAIN antes/depois.)
-- Obs.: criado em db/indice.sql para que o "antes" possa ser demonstrado.
