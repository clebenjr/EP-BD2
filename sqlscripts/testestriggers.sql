-- Define o schema a ser utilizado
SET search_path TO ep2_bd2;

-- Testes para Trigger 1: fn_check_max_tres_chefes_por_divisao()
-- Regra: Uma divisão pode ser dirigida por no máximo três chefes militares.
-- Pré-requisito para este teste:
-- 1. A tabela 'chefe_militar' permite múltiplos chefes por divisão (sem UNIQUE em id_divisao, id_grupo_armado_divisao sozinhos).
-- 2. A constraint UNIQUE em chefe_militar é em (nome_lider_politico, id_grupo_lider_politico).
--    Isso significa que para ter 3 chefes na mesma divisão, eles devem reportar a 3 líderes diferentes.

-- Cenário: Divisão ID 1 do Grupo Armado ID 1.
-- No script de povoamento:
-- Chefe Militar ID 1 (Alistair Vance, Grupo 1) comanda Divisão 1 do Grupo 1.

BEGIN;
-- Adicionar 2 líderes políticos fictícios para o Grupo Armado 1 para poder atribuir mais chefes.
INSERT INTO lider_politico (nome, id_grupo, descricao_apoio) 
VALUES ('Líder Bravo', 1, 'Apoio tático'), ('Líder Charlie', 1, 'Apoio logístico')
ON CONFLICT (nome, id_grupo) DO NOTHING; -- Evita erro se já existirem de testes anteriores

-- Chefe Militar 1 (já existe): (DEFAULT, 'General de Brigada', 'Alistair Vance', 1, 1, 1)
-- Adicionar Chefe Militar 2 para Divisão 1 do Grupo 1
INSERT INTO chefe_militar (faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao)
VALUES ('Major', 'Líder Bravo', 1, 1, 1);
RAISE NOTICE 'Chefe Militar 2 adicionado à Divisão 1 do Grupo 1.';

-- Adicionar Chefe Militar 3 para Divisão 1 do Grupo 1
INSERT INTO chefe_militar (faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao)
VALUES ('Capitão', 'Líder Charlie', 1, 1, 1);
RAISE NOTICE 'Chefe Militar 3 adicionado à Divisão 1 do Grupo 1.';

-- Verificar contagem atual (deve ser 3)
SELECT COUNT(*) AS ChefesNaDivisao1Grupo1 FROM chefe_militar WHERE id_divisao = 1 AND id_grupo_armado_divisao = 1;

-- Tentar adicionar Chefe Militar 4 para Divisão 1 do Grupo 1 (DEVE FALHAR)
RAISE NOTICE 'Tentando adicionar o 4º Chefe Militar à Divisão 1 do Grupo 1...';
INSERT INTO lider_politico (nome, id_grupo, descricao_apoio) 
VALUES ('Líder Delta', 1, 'Apoio moral')
ON CONFLICT (nome, id_grupo) DO NOTHING;

INSERT INTO chefe_militar (faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao)
VALUES ('Tenente', 'Líder Delta', 1, 1, 1); 
-- ESPERA-SE ERRO: "Operação inválida: A divisão ID 1 (do Grupo ID 1) já possui o máximo de 3 chefes militares."
ROLLBACK;
RAISE NOTICE E'--------------------------------------\nTeste do Trigger 1 concluído.\n--------------------------------------';

-- Testes para Trigger 2: fn_check_min_dois_grupos_por_conflito()
-- Regra: Um conflito deve ter no mínimo dois grupos armados participando ATIVAMENTE.
-- O trigger atua AFTER DELETE em participa_grupo.

-- Cenário: Conflito ID 4 ("Guerra dos Balcãs Ocidentais")
-- No script de povoamento, Grupos 21 e 5 participam ativamente.
BEGIN;
RAISE NOTICE 'Verificando grupos ativos no Conflito ID 4 antes do delete:';
SELECT ga.nome AS grupo_participante
FROM participa_grupo pg
JOIN grupo_armado ga ON pg.id_grupo = ga.id
WHERE pg.id_conflito = 4 AND pg.data_de_saida IS NULL;
-- Deveria mostrar 2 grupos (Grupo ID 21 e Grupo ID 5)

RAISE NOTICE 'Tentando remover a participação do Grupo ID 5 do Conflito ID 4...';
-- Se removermos o grupo 5, o conflito 4 ficará com apenas 1 grupo ativo (grupo 21).
DELETE FROM participa_grupo 
WHERE id_conflito = 4 AND id_grupo = 5 AND data_de_incorporacao = '2023-02-01'; 
-- ESPERA-SE ERRO: "Operação inválida: O conflito ID 4 deve ter pelo menos dois grupos armados participando ativamente..."
ROLLBACK;
RAISE NOTICE E'--------------------------------------\nTeste do Trigger 2 concluído.\n--------------------------------------';

-- Testes para Trigger 3: fn_update_grupo_total_baixas()
-- Regra: Manter a consistência de 'total_baixas' em 'grupo_armado'.

-- Teste 3.1: INSERT em 'divisao'
BEGIN;
RAISE NOTICE 'Teste 3.1: INSERT em divisao';
SELECT nome, total_baixas FROM grupo_armado WHERE id = 1; -- Baixas do Grupo 1 antes
INSERT INTO divisao (id, id_grupo, barcos, homens, tanques, avioes, baixas) 
VALUES (3, 1, 1, 100, 5, 1, 50); -- Nova divisão (ID 3) para Grupo 1 com 50 baixas
RAISE NOTICE 'Divisão 3 (ID 3) para Grupo 1 inserida com 50 baixas.';
SELECT nome, total_baixas FROM grupo_armado WHERE id = 1; -- Baixas do Grupo 1 DEPOIS (deve ter aumentado em 50)
ROLLBACK;

-- Teste 3.2: UPDATE de 'baixas' em 'divisao'
BEGIN;
RAISE NOTICE E'\nTeste 3.2: UPDATE de baixas em divisao';
SELECT nome, total_baixas FROM grupo_armado WHERE id = 1; -- Baixas do Grupo 1 antes
SELECT id, baixas FROM divisao WHERE id = 1 AND id_grupo = 1; -- Baixas da Divisão 1 (Grupo 1) antes
UPDATE divisao SET baixas = baixas + 25 WHERE id = 1 AND id_grupo = 1; -- Aumentar baixas da Divisão 1 em 25
RAISE NOTICE 'Baixas da Divisão 1 (Grupo 1) aumentadas em 25.';
SELECT nome, total_baixas FROM grupo_armado WHERE id = 1; -- Baixas do Grupo 1 DEPOIS (deve ter aumentado em 25)
SELECT id, baixas FROM divisao WHERE id = 1 AND id_grupo = 1; -- Baixas da Divisão 1 (Grupo 1) depois
ROLLBACK;

-- Teste 3.3: DELETE em 'divisao'
BEGIN;
RAISE NOTICE E'\nTeste 3.3: DELETE em divisao';
SELECT nome, total_baixas FROM grupo_armado WHERE id = 1; -- Baixas do Grupo 1 antes
SELECT baixas FROM divisao WHERE id = 2 AND id_grupo = 1; -- Baixas da Divisão 2 (Grupo 1) que será deletada (150 no populate)
DELETE FROM divisao WHERE id = 2 AND id_grupo = 1; -- Deletar Divisão 2 do Grupo 1
RAISE NOTICE 'Divisão 2 (Grupo 1) deletada.';
SELECT nome, total_baixas FROM grupo_armado WHERE id = 1; -- Baixas do Grupo 1 DEPOIS (deve ter diminuído em 150)
ROLLBACK;

-- Teste 3.4: UPDATE de 'id_grupo' em 'divisao' (mover divisão)
BEGIN;
RAISE NOTICE E'\nTeste 3.4: UPDATE de id_grupo em divisao (mover divisão)';
SELECT id, nome, total_baixas FROM grupo_armado WHERE id IN (1, 2) ORDER BY id; -- Baixas dos Grupos 1 e 2 antes
SELECT baixas FROM divisao WHERE id = 1 AND id_grupo = 1; -- Baixas da Divisão 1 (Grupo 1) que será movida (300 no populate)
-- Mover Divisão 1 (ID 1) do Grupo 1 para o Grupo 2
UPDATE divisao SET id_grupo = 2 WHERE id = 1 AND id_grupo = 1; 
RAISE NOTICE 'Divisão 1 (originalmente do Grupo 1) movida para o Grupo 2.';
SELECT id, nome, total_baixas FROM grupo_armado WHERE id IN (1, 2) ORDER BY id; -- Baixas dos Grupos 1 e 2 DEPOIS
-- Total do Grupo 1 deve diminuir em 300. Total do Grupo 2 deve aumentar em 300.
ROLLBACK;
RAISE NOTICE E'--------------------------------------\nTeste do Trigger 3 concluído.\n--------------------------------------';

-- Testes para Trigger 4: fn_set_numero_divisao_no_grupo()
-- Regra: Gerar 'numero_divisao_no_grupo' sequencialmente na inserção se não fornecido.
-- Pré-requisito: A coluna 'numero_divisao_no_grupo' e a constraint UNIQUE(id_grupo, numero_divisao_no_grupo)
-- devem existir na tabela 'divisao'. O script de povoamento NÃO popula esta coluna.
-- Para este teste funcionar, vamos assumir que ela foi adicionada ao schema
-- e que as divisões existentes para o grupo 1 (ID 1 e ID 2) têm numero_divisao_no_grupo 1 e 2.

BEGIN;
RAISE NOTICE 'Teste 4.1: INSERT em divisao sem numero_divisao_no_grupo';
-- Simular que as divisões existentes do grupo 1 já têm numero_divisao_no_grupo
-- Isso seria feito após a criação da coluna e antes do teste do trigger.
-- Para o teste, vamos assumir que elas são 1 e 2.
-- O script de povoamento insere divisao id=1, id_grupo=1 e divisao id=2, id_grupo=1.

-- Antes de inserir, vamos ver os números existentes (ou a ausência deles)
SELECT id, id_grupo, numero_divisao_no_grupo FROM divisao WHERE id_grupo = 1 ORDER BY id;

-- Se numero_divisao_no_grupo ainda não foi populado para os existentes, este teste pode não ser ideal.
-- Assumindo que o trigger está ativo e a coluna existe, e que um MAX daria 0 se não houvesse entradas.
-- A primeira inserção para o grupo 1 deve resultar em numero_divisao_no_grupo = 1
-- Se já temos divisões 1 e 2 para o grupo 1, a próxima deveria ser 3.
-- Vamos limpar e inserir para o grupo 1 para ter controle:
DELETE FROM chefe_militar WHERE id_grupo_armado_divisao = 1; -- Limpar dependências
DELETE FROM divisao WHERE id_grupo = 1;
RAISE NOTICE 'Divisões do grupo 1 limpas para o teste do trigger 4.';

INSERT INTO divisao (id, id_grupo, barcos, homens, tanques, avioes, baixas) 
VALUES (101, 1, 1, 10, 1, 0, 10); -- numero_divisao_no_grupo deve ser 1
RAISE NOTICE 'Divisão 101 (Grupo 1) inserida.';
SELECT id, id_grupo, numero_divisao_no_grupo FROM divisao WHERE id_grupo = 1 AND id = 101;

INSERT INTO divisao (id, id_grupo, barcos, homens, tanques, avioes, baixas) 
VALUES (102, 1, 2, 20, 2, 0, 20); -- numero_divisao_no_grupo deve ser 2
RAISE NOTICE 'Divisão 102 (Grupo 1) inserida.';
SELECT id, id_grupo, numero_divisao_no_grupo FROM divisao WHERE id_grupo = 1 AND id = 102;

-- Teste 4.2: INSERT em divisao especificando numero_divisao_no_grupo (trigger não deve sobrescrever)
RAISE NOTICE E'\nTeste 4.2: INSERT em divisao especificando numero_divisao_no_grupo';
INSERT INTO divisao (id, id_grupo, numero_divisao_no_grupo, barcos, homens, tanques, avioes, baixas) 
VALUES (103, 1, 10, 3, 30, 3, 0, 30); -- Fornecendo numero_divisao_no_grupo = 10
RAISE NOTICE 'Divisão 103 (Grupo 1) inserida com numero_divisao_no_grupo = 10.';
SELECT id, id_grupo, numero_divisao_no_grupo FROM divisao WHERE id_grupo = 1 AND id = 103; 
-- Deve mostrar numero_divisao_no_grupo = 10

ROLLBACK;
RAISE NOTICE E'--------------------------------------\nTeste do Trigger 4 concluído.\n--------------------------------------';

RAISE NOTICE 'Todos os testes de triggers concluídos.';

