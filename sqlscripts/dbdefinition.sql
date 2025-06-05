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
CREATE TABLE regioes_conflito (
    id_conflito INTEGER NOT NULL,
    regiao VARCHAR(255) NOT NULL,
    PRIMARY KEY(id_conflito, regiao),
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Causas dos conflitos: Econômicos
CREATE TABLE materias_primas_conflito (
    id_conflito INTEGER NOT NULL,
    materia_prima VARCHAR(255) NOT NULL,
    PRIMARY KEY(id_conflito, materia_prima),
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Causas dos conflitos: Religiosos
CREATE TABLE religioes_conflito (
    id_conflito INTEGER NOT NULL,
    religiao VARCHAR(255) NOT NULL,
    PRIMARY KEY(id_conflito, religiao),
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Causas dos conflitos: Raciais
CREATE TABLE etnias_conflito (
    id_conflito INTEGER NOT NULL,
    etnia VARCHAR(255) NOT NULL,
    PRIMARY KEY(id_conflito, etnia),
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Grupos armados
CREATE TABLE grupo_armado (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE,
    total_baixas INTEGER NOT NULL DEFAULT 0 CHECK (total_baixas >= 0) -- Coluna adicionada
);

-- Divisões dos grupos armados
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
    PRIMARY KEY(id, id_grupo)
);

-- Líderes políticos
CREATE TABLE lider_politico (
    nome VARCHAR(255) NOT NULL,
    id_grupo INTEGER NOT NULL,
    descricao_apoio TEXT,
    PRIMARY KEY (nome, id_grupo),
    FOREIGN KEY (id_grupo) REFERENCES grupo_armado(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Chefes militares
CREATE TABLE chefe_militar (
    id SERIAL PRIMARY KEY,
    faixa_hierarquica VARCHAR(255) NOT NULL,
    nome_lider_politico VARCHAR(255) NOT NULL, 
    id_grupo_lider_politico INTEGER NOT NULL, 
    id_divisao INTEGER NOT NULL, 
    id_grupo_armado_divisao INTEGER NOT NULL,
    UNIQUE (nome_lider_politico, id_grupo_lider_politico),
    FOREIGN KEY (nome_lider_politico, id_grupo_lider_politico) REFERENCES lider_politico(nome, id_grupo) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_divisao, id_grupo_armado_divisao) REFERENCES divisao(id, id_grupo) ON DELETE CASCADE ON UPDATE CASCADE 
);

-- Participação dos grupos nos conflitos
CREATE TABLE participa_grupo (
    id_conflito INTEGER NOT NULL,
    id_grupo INTEGER NOT NULL,
    data_de_incorporacao DATE NOT NULL,
    data_de_saida DATE, 
    PRIMARY KEY(id_conflito, id_grupo, data_de_incorporacao), 
    FOREIGN KEY (id_conflito) REFERENCES conflito(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_grupo) REFERENCES grupo_armado(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (data_de_saida IS NULL OR data_de_saida >= data_de_incorporacao)
);

-- Armas
CREATE TABLE arma (
    tipo VARCHAR(255) PRIMARY KEY,
    capacidade_destrutiva INTEGER NOT NULL CHECK (capacidade_destrutiva >= 0 AND capacidade_destrutiva <= 10) 
);

-- Traficantes
CREATE TABLE traficante (
    nome VARCHAR(255) PRIMARY KEY
);

-- Relação: Traficante possui tipos de armas (estoque potencial)
CREATE TABLE possui_arma_traficante ( 
    tipo_arma VARCHAR(255),
    nome_traficante VARCHAR(255),
    quantidade_disponivel INTEGER NOT NULL CHECK (quantidade_disponivel >= 0),
    PRIMARY KEY (tipo_arma, nome_traficante),
    FOREIGN KEY (tipo_arma) REFERENCES arma(tipo) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (nome_traficante) REFERENCES traficante(nome) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Relação: Traficante fornece armas a Grupo Armado
CREATE TABLE fornece_arma_grupo ( 
    id_grupo_armado INTEGER,
    tipo_arma VARCHAR(255),
    nome_traficante VARCHAR(255),
    quantidade_fornecida INTEGER NOT NULL CHECK (quantidade_fornecida > 0),
    PRIMARY KEY (id_grupo_armado, tipo_arma, nome_traficante), 
    FOREIGN KEY (id_grupo_armado) REFERENCES grupo_armado(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tipo_arma) REFERENCES arma(tipo) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (nome_traficante) REFERENCES traficante(nome) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Organizações mediadoras
CREATE TABLE organizacao_mediadora (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('Governamental', 'Não Governamental', 'Internacional'))
);

-- Dependências entre organizações
CREATE TABLE depende_organizacao (
    id_organizacao_mediada INTEGER NOT NULL,
    id_organizacao_mediadora INTEGER NOT NULL,
    PRIMARY KEY (id_organizacao_mediada, id_organizacao_mediadora),
    FOREIGN KEY (id_organizacao_mediada) REFERENCES organizacao_mediadora(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_organizacao_mediadora) REFERENCES organizacao_mediadora(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Participação das organizações nos conflitos
CREATE TABLE participa_organizacao (
    id_conflito INTEGER NOT NULL,
    id_organizacao INTEGER NOT NULL,
    data_incorporacao DATE NOT NULL,
    data_saida DATE, 
    tipo_ajuda VARCHAR(30) NOT NULL CHECK (tipo_ajuda IN ('Médica', 'Diplomática', 'Presencial')),
    numero_pessoas INTEGER NOT NULL CHECK (numero_pessoas >= 0),
    PRIMARY KEY(id_conflito, id_organizacao, data_incorporacao), 
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

