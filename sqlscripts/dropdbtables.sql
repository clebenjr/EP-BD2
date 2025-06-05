-- Define o schema a ser utilizado (se o schema não for o padrão da sessão)
-- SET search_path TO ep2_bd2;

DROP TABLE IF EXISTS 
    ep2_bd2.afeta,
    ep2_bd2.arma,
    ep2_bd2.chefe_militar,
    ep2_bd2.conflito,
    ep2_bd2.depende_organizacao,
    ep2_bd2.dialoga,
    ep2_bd2.divisao,
    ep2_bd2.etnias_conflito,          -- Nome atualizado
    ep2_bd2.fornece_arma_grupo,       -- Nome atualizado
    ep2_bd2.grupo_armado,
    ep2_bd2.lider_politico,
    ep2_bd2.materias_primas_conflito, -- Nome atualizado
    ep2_bd2.organizacao_mediadora,
    ep2_bd2.pais,
    ep2_bd2.participa_grupo,
    ep2_bd2.participa_organizacao,
    ep2_bd2.possui_arma_traficante,   -- Nome atualizado
    ep2_bd2.regioes_conflito,         -- Nome atualizado
    ep2_bd2.religioes_conflito,       -- Nome atualizado
    ep2_bd2.traficante
CASCADE;

-- Nota: Se você tiver outras tabelas ou objetos no schema ep2_bd2 que não foram
-- mencionados no script de criação fornecido, eles não serão incluídos neste DROP.
-- Este comando assume que as tabelas listadas são todas as que você deseja remover do schema ep2_bd2.
-- O uso de "ep2_bd2." antes de cada nome de tabela garante que você está excluindo
-- as tabelas do schema correto, caso seu search_path não esteja configurado ou
-- você queira ser explícito.
