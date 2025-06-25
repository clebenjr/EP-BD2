-- Consulta do gráfico
SELECT 'Por Região' AS TipoDeConflito,
    COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
FROM Regioes_conflito
UNION ALL
SELECT 'Por Matéria Prima' AS TipoDeConflito,
    COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
FROM Materias_Primas_conflito
UNION ALL
SELECT 'Por Religião' AS TipoDeConflito,
    COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
FROM religioes_conflito
UNION ALL
SELECT 'Por Etnia' AS TipoDeConflito,
    COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
FROM Etnias_conflito;


-- Consulta traficantes que fornecem Barret M82 ou M200 Intervention
SELECT DISTINCT t.nome AS NomeTraficante,
    ga.nome AS NomeGrupoArmado,
    a.tipo AS TipoArma
FROM traficante t
    JOIN fornece_arma_grupo fag ON t.nome = fag.nome_traficante
    JOIN grupo_armado ga ON fag.id_grupo_armado = ga.id
    JOIN arma a ON fag.tipo_arma = a.tipo
WHERE a.tipo = 'Barret M82'
    OR a.tipo = 'M200 Intervention';


-- Consulta 5 maiores conflitos
SELECT nome,
    numero_de_mortos,
    numero_de_feridos
FROM conflito
ORDER BY numero_de_mortos DESC
LIMIT 5;


-- Consulta 5 maiores organizações mediadoras
SELECT OM.nome AS NomeOrganizacao,
    OM.tipo as Tipo,
    COUNT(PO.Id_Organizacao) AS NumeroDeMediacoes
FROM participa_organizacao PO
    INNER JOIN organizacao_mediadora OM ON PO.id_organizacao = OM.id
GROUP BY OM.nome,
    OM.tipo
ORDER BY NumeroDeMediacoes DESC
LIMIT 5;


-- Consulta 5 maiores grupos armados
SELECT GA.nome AS NomeGrupoArmado,
    SUM(F.Quantidade_fornecida) AS TotalArmasFornecidas
FROM fornece_arma_grupo F
    INNER JOIN grupo_armado GA ON F.id_grupo_armado = GA.id
GROUP BY GA.nome
ORDER BY TotalArmasFornecidas DESC
LIMIT 5;


-- Consulta país com maior número de conflitos religiosos
SELECT A.nome_pais,
    COUNT(DISTINCT R.id_conflito) AS NumeroDeConflitosReligiosos
FROM afeta A
    INNER JOIN religioes_conflito R ON a.id_conflito = R.id_conflito
GROUP BY A.nome_pais
ORDER BY NumeroDeConflitosReligiosos DESC
LIMIT 1;
