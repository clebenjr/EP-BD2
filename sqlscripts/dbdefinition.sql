-- Criação do schema
CREATE SCHEMA IF NOT EXISTS ep2_bd2;
SET search_path TO ep2_bd2;

-- Tabela de países
CREATE TABLE pais (
    nome VARCHAR(255) PRIMARY KEY
);

-- Tabela de conflitos
CREATE TABLE conflito (
    id SERIAL PRIMARY KEY,
    numero_de_mortos INTEGER NOT NULL CHECK (numero_de_mortos >= 0),
    numero_de_feridos INTEGER NOT NULL CHECK (numero_de_feridos >= 0),
    nome VARCHAR(255) NOT NULL
);

-- Conflitos afetando países (relação N:M)
CREATE TABLE afeta (
    nome_pais VARCHAR(255) NOT NULL,
    id_conflito INTEGER NOT NULL,
    PRIMARY KEY (nome_pais, id_conflito),
    FOREIGN KEY (nome_pais) REFERENCES pais(nome) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Causas dos conflitos: Territoriais
CREATE TABLE regioes_conflito ( -- Renomeado de 'regioes' para evitar ambiguidade e pluralizar
    id_conflito INTEGER NOT NULL,
    regiao VARCHAR(255) NOT NULL,
    PRIMARY KEY(id_conflito, regiao),
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Causas dos conflitos: Econômicos
CREATE TABLE materias_primas_conflito ( -- Renomeado de 'materias_primas'
    id_conflito INTEGER NOT NULL,
    materia_prima VARCHAR(255) NOT NULL,
    PRIMARY KEY(id_conflito, materia_prima),
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Causas dos conflitos: Religiosos
CREATE TABLE religioes_conflito ( -- Renomeado de 'religioes'
    id_conflito INTEGER NOT NULL,
    religiao VARCHAR(255) NOT NULL,
    PRIMARY KEY(id_conflito, religiao),
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Causas dos conflitos: Raciais
CREATE TABLE etnias_conflito ( -- Renomeado de 'etnias'
    id_conflito INTEGER NOT NULL,
    etnia VARCHAR(255) NOT NULL,
    PRIMARY KEY(id_conflito, etnia),
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Grupos armados
CREATE TABLE grupo_armado (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE -- Nome do grupo armado deve ser único
);

-- Divisões dos grupos armados
-- O enunciado diz "As divisões dentro de um grupo armado são enumeradas consecutivamente".
-- O 'id SERIAL' da divisão é um identificador único global.
-- Se uma numeração *por grupo* for necessária (ex: Divisão 1 do Grupo A, Divisão 2 do Grupo A),
-- um campo adicional e lógica de aplicação seriam necessários.
CREATE TABLE divisao (
    id INTEGER NOT NULL,
    id_grupo INTEGER NOT NULL,
    -- numero_divisao_no_grupo INTEGER, -- Campo opcional para numeração dentro do grupo
   barcos INTEGER NOT NULL DEFAULT 0 CHECK (barcos >= 0),
    homens INTEGER NOT NULL DEFAULT 0 CHECK (homens >= 0),
    tanques INTEGER NOT NULL DEFAULT 0 CHECK (tanques >= 0),
    avioes INTEGER NOT NULL DEFAULT 0 CHECK (avioes >= 0),
    baixas INTEGER NOT NULL DEFAULT 0 CHECK (baixas >= 0),
    FOREIGN KEY (id_grupo) REFERENCES grupo_armado(id) ON DELETE CASCADE ON UPDATE CASCADE,
    -- Se 'numero_divisao_no_grupo' for adicionado:
    -- UNIQUE (id_grupo, numero_divisao_no_grupo)
PRIMARY KEY(id, id_grupo)
);

-- Líderes políticos
-- Um líder é identificado pelo nome E pelo grupo que lidera.
CREATE TABLE lider_politico (
    nome VARCHAR(255) NOT NULL,
    id_grupo INTEGER NOT NULL,
    descricao_apoio TEXT, -- Alterado para TEXT para descrições mais longas
    PRIMARY KEY (nome, id_grupo),
    FOREIGN KEY (id_grupo) REFERENCES grupo_armado(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Chefes militares
-- "Cada chefe militar não pode liderar mais de uma divisão." -> id_divisao UNIQUE
-- "Cada divisão pode ser dirigida conjuntamente no máximo por três chefes militares."
-- Esta última restrição (máximo 3) é complexa para impor via DDL simples
-- e geralmente é tratada na lógica da aplicação ou com triggers.
CREATE TABLE chefe_militar (
    id SERIAL PRIMARY KEY,
    faixa_hierarquica VARCHAR(255) NOT NULL,
    nome_lider_politico VARCHAR(255) NOT NULL, -- Nome do líder político a quem obedece
    id_grupo_lider_politico INTEGER NOT NULL, -- ID do grupo desse líder político
    id_divisao INTEGER NOT NULL, -- Garante que um chefe militar lidera no máximo uma divisão
                               -- Pode ser NULL se o chefe não estiver atualmente comandando uma divisão específica
   UNIQUE (nome_lider_politico, id_grupo_lider_politico),
    FOREIGN KEY (nome_lider_politico, id_grupo_lider_politico) REFERENCES lider_politico(nome, id_grupo) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_divisao) REFERENCES divisao(id) ON DELETE SET NULL ON UPDATE CASCADE -- Se a divisão for excluída, o chefe fica sem divisão (ou poderia ser RESTRICT)
);

-- Participação dos grupos nos conflitos
CREATE TABLE participa_grupo (
    id_conflito INTEGER NOT NULL,
    id_grupo INTEGER NOT NULL,
    data_de_incorporacao DATE NOT NULL,
    data_de_saida DATE, -- Pode ser NULL se o grupo ainda estiver ativo no conflito
    PRIMARY KEY(id_conflito, id_grupo, data_de_incorporacao), -- data_de_incorporacao na PK para permitir reingresso
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_grupo) REFERENCES grupo_armado(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (data_de_saida IS NULL OR data_de_saida >= data_de_incorporacao)
);

-- Armas
CREATE TABLE arma (
    tipo VARCHAR(255) PRIMARY KEY,
    capacidade_destrutiva INTEGER NOT NULL CHECK (capacidade_destrutiva >= 0 AND capacidade_destrutiva <= 10) -- Exemplo de escala
);

-- Traficantes
CREATE TABLE traficante (
    nome VARCHAR(255) PRIMARY KEY
);

-- Relação: Traficante possui tipos de armas (estoque potencial)
CREATE TABLE possui_arma_traficante ( -- Renomeado de 'possui'
    tipo_arma VARCHAR(255),
    nome_traficante VARCHAR(255),
    quantidade_disponivel INTEGER NOT NULL CHECK (quantidade_disponivel >= 0),
    PRIMARY KEY (tipo_arma, nome_traficante),
    FOREIGN KEY (tipo_arma) REFERENCES arma(tipo) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (nome_traficante) REFERENCES traficante(nome) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Relação: Traficante fornece armas a Grupo Armado
CREATE TABLE fornece_arma_grupo ( -- Renomeado de 'fornece'
    id_grupo_armado INTEGER,
    tipo_arma VARCHAR(255),
    nome_traficante VARCHAR(255),
    quantidade_fornecida INTEGER NOT NULL CHECK (quantidade_fornecida > 0),
     PRIMARY KEY (id_grupo_armado, tipo_arma, nome_traficante), -- 
    FOREIGN KEY (id_grupo_armado) REFERENCES grupo_armado(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tipo_arma) REFERENCES arma(tipo) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (nome_traficante) REFERENCES traficante(nome) ON DELETE RESTRICT ON UPDATE CASCADE
    -- FOREIGN KEY (tipo_arma, nome_traficante) REFERENCES possui_arma_traficante(tipo_arma, nome_traficante) -- Opcional: garantir que o traficante possui o tipo de arma
);

-- Organizações mediadoras
CREATE TABLE organizacao_mediadora (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('Governamental', 'Não Governamental', 'Internacional')));

-- Dependências entre organizações
CREATE TABLE depende_organizacao (
    id_organizacao_mediada INTEGER NOT NULL,
    id_organizacao_mediadora INTEGER NOT NULL,
    PRIMARY KEY (id_organizacao_mediada, id_organizacao_mediadora),
    FOREIGN KEY (id_organizacao_mediada) REFERENCES organizacao_mediadora(id),
    FOREIGN KEY (id_organizacao_mediadora) REFERENCES organizacao_mediadora(id)
);

-- Participação das organizações nos conflitos
CREATE TABLE participa_organizacao (
    id_conflito INTEGER NOT NULL,
    id_organizacao INTEGER NOT NULL,
    data_incorporacao DATE NOT NULL,
    data_saida DATE, -- Pode ser NULL se a organização ainda estiver ativa
    tipo_ajuda VARCHAR(30) NOT NULL CHECK (tipo_ajuda IN ('Médica', 'Diplomática', 'Presencial')),
    numero_pessoas INTEGER NOT NULL CHECK (numero_pessoas >= 0),
    PRIMARY KEY(id_conflito, id_organizacao, data_incorporacao), -- data_incorporacao na PK
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_organizacao) REFERENCES organizacao_mediadora(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (data_saida IS NULL OR data_saida >= data_incorporacao)
);

-- Diálogo entre líderes políticos e organizações mediadoras
CREATE TABLE dialoga (
    id_organizacao INTEGER NOT NULL,
    nome_lider_politico VARCHAR(255) NOT NULL,
    id_grupo_lider_politico INTEGER NOT NULL,
    PRIMARY KEY(id_organizacao, nome_lider_politico, id_grupo_lider_politico),
    FOREIGN KEY (id_organizacao) REFERENCES organizacao_mediadora(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nome_lider_politico, id_grupo_lider_politico) REFERENCES lider_politico(nome, id_grupo) ON DELETE CASCADE ON UPDATE CASCADE
);
