-- Define o schema a ser utilizado (se necessário em cada sessão/script)
SET search_path TO ep2_bd2;

-- 1. Gerar um gráfico, histograma, por tipo de conflito e número de conflitos.
SELECT
    'Por Região' AS TipoDeConflito,
    COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
FROM
    regioes_conflito

UNION ALL

SELECT
    'Por Matéria Prima' AS TipoDeConflito,
    COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
FROM
    materias_primas_conflito

UNION ALL

SELECT
    'Por Religião' AS TipoDeConflito,
    COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
FROM
    religioes_conflito

UNION ALL

SELECT
    'Por Etnia' AS TipoDeConflito,
    COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
FROM
    etnias_conflito;

Fornecimento de Barret M82 ou M200 Intervention Traficantes 
-- 2. Listar os traficantes e os grupos armados (Nome) para os quais os traficantes fornecem armas “Barret M82” ou “M200 intervention”.
SELECT DISTINCT
    t.nome AS NomeTraficante,
    ga.nome AS NomeGrupoArmado,
    a.tipo AS TipoArma -- Coluna adicionada para mostrar o nome da arma
FROM
    traficante t
JOIN
    fornece_arma_grupo fag ON t.nome = fag.nome_traficante
JOIN
    grupo_armado ga ON fag.id_grupo_armado = ga.id
JOIN
    arma a ON fag.tipo_arma = a.tipo
WHERE
    a.tipo = 'Barret M82' OR a.tipo = 'M200 Intervention';


-- 3. Listar os 5 maiores conflitos em número de mortos.
SELECT
    nome,
    numero_de_mortos
FROM
    conflito
ORDER BY
    numero_de_mortos DESC
LIMIT 5;


-- 4. Listar as 5 maiores organizações em número de mediações.
-- (Considerando que "mediação" é uma participação da organização em um conflito)
SELECT
    OM.nome AS NomeOrganizacao,
    COUNT(DISTINCT PO.id_conflito) AS NumeroDeMediacoes -- Conta conflitos distintos mediados
    -- Se quiser contar cada entrada em participa_organizacao como uma "mediação":
    -- COUNT(*) AS NumeroDeParticipacoesEmMediacao
FROM
    participa_organizacao PO
INNER JOIN
    organizacao_mediadora OM ON PO.id_organizacao = OM.id
GROUP BY
    OM.nome
ORDER BY
    NumeroDeMediacoes DESC
LIMIT 5;


-- 5. Listar os 5 maiores grupos armados com maior número de armas fornecidas.
SELECT
    GA.nome AS NomeGrupoArmado,
    SUM(FAG.quantidade_fornecida) AS TotalArmasFornecidas
FROM
    fornece_arma_grupo FAG
INNER JOIN
    grupo_armado GA ON FAG.id_grupo_armado = GA.id
GROUP BY
    GA.nome
ORDER BY
    TotalArmasFornecidas DESC
LIMIT 5;


-- 6. Listar o país e número de conflitos com maior número de conflitos religiosos.
SELECT
    A.nome_pais,
    COUNT(DISTINCT RC.id_conflito) AS NumeroDeConflitosReligiosos
FROM
    afeta A
INNER JOIN
    religioes_conflito RC ON A.id_conflito = RC.id_conflito
GROUP BY
    A.nome_pais
ORDER BY
    NumeroDeConflitosReligiosos DESC
LIMIT 1;

-- 7. Listar todos os conflitos, os países envolvidos e os detalhes de cada tipo de causa.
SELECT
    c.nome AS NomeConflito,
    c.numero_de_mortos,
    c.numero_de_feridos,
    COALESCE(paises.PaisesEnvolvidos, 'Nenhum país diretamente afetado registrado') AS PaisesEnvolvidos,
    COALESCE(reg.CausasTerritoriais, 'Nenhuma causa territorial registrada') AS CausasTerritoriais,
    COALESCE(mat.CausasEconomicas, 'Nenhuma causa económica registrada') AS CausasEconomicas,
    COALESCE(rel.CausasReligiosas, 'Nenhuma causa religiosa registrada') AS CausasReligiosas,
    COALESCE(etn.CausasEtnicas, 'Nenhuma causa étnica/racial registrada') AS CausasEtnicas
FROM
    conflito c
LEFT JOIN
    (SELECT id_conflito, STRING_AGG(DISTINCT nome_pais, ', ') AS PaisesEnvolvidos
     FROM afeta
     GROUP BY id_conflito) AS paises ON c.id = paises.id_conflito
LEFT JOIN
    (SELECT id_conflito, STRING_AGG(DISTINCT regiao, ', ') AS CausasTerritoriais
     FROM regioes_conflito
     GROUP BY id_conflito) AS reg ON c.id = reg.id_conflito
LEFT JOIN
    (SELECT id_conflito, STRING_AGG(DISTINCT materia_prima, ', ') AS CausasEconomicas
     FROM materias_primas_conflito
     GROUP BY id_conflito) AS mat ON c.id = mat.id_conflito
LEFT JOIN
    (SELECT id_conflito, STRING_AGG(DISTINCT religiao, ', ') AS CausasReligiosas
     FROM religioes_conflito
     GROUP BY id_conflito) AS rel ON c.id = rel.id_conflito
LEFT JOIN
    (SELECT id_conflito, STRING_AGG(DISTINCT etnia, ', ') AS CausasEtnicas
     FROM etnias_conflito
     GROUP BY id_conflito) AS etn ON c.id = etn.id_conflito
ORDER BY
    c.nome;
