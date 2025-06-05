-- Define o schema a ser utilizado
SET search_path TO ep2_bd2;

-- Testes para Trigger 1: fn_check_max_tres_chefes_por_divisao()
-- --------------------------------------
-- INICIANDO TESTES PARA TRIGGER 1: Máximo 3 Chefes por Divisão
-- --------------------------------------
BEGIN; -- Transação SQL para este bloco de teste
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    RAISE NOTICE 'Teste 1: Configurando cenário para Divisão ID 1, Grupo ID 1.';
    -- Adicionar 2 líderes políticos fictícios para o Grupo Armado 1 para poder atribuir mais chefes.
    INSERT INTO lider_politico (nome, id_grupo, descricao_apoio) 
    VALUES ('Líder Bravo', 1, 'Apoio tático'), ('Líder Charlie', 1, 'Apoio logístico')
    ON CONFLICT (nome, id_grupo) DO NOTHING; 
    RAISE NOTICE ' -> Líderes Bravo e Charlie para Grupo 1 inseridos/existentes.';

    -- Chefe Militar 1 (já existe do povoamento): (DEFAULT, 'General de Brigada', 'Alistair Vance', 1, 1, 1)
    -- Adicionar Chefe Militar 2 para Divisão 1 do Grupo 1
    INSERT INTO chefe_militar (faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao)
    VALUES ('Major', 'Líder Bravo', 1, 1, 1);
    RAISE NOTICE ' -> Chefe Militar 2 (Líder Bravo) adicionado à Divisão 1 do Grupo 1.';

    -- Adicionar Chefe Militar 3 para Divisão 1 do Grupo 1
    INSERT INTO chefe_militar (faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao)
    VALUES ('Capitão', 'Líder Charlie', 1, 1, 1);
    RAISE NOTICE ' -> Chefe Militar 3 (Líder Charlie) adicionado à Divisão 1 do Grupo 1.';

    -- Verificar contagem atual
    SELECT COUNT(*) INTO v_count FROM chefe_militar WHERE id_divisao = 1 AND id_grupo_armado_divisao = 1;
    RAISE NOTICE ' -> Chefes atualmente na Divisão 1 do Grupo 1: % (Esperado: 3)', v_count;

    -- Tentar adicionar Chefe Militar 4 para Divisão 1 do Grupo 1 (DEVE FALHAR)
    RAISE NOTICE ' -> Tentando adicionar o 4º Chefe Militar (Líder Delta) à Divisão 1 do Grupo 1...';
    INSERT INTO lider_politico (nome, id_grupo, descricao_apoio) 
    VALUES ('Líder Delta', 1, 'Apoio moral')
    ON CONFLICT (nome, id_grupo) DO NOTHING;
    RAISE NOTICE '   -> Líder Delta para Grupo 1 inserido/existente.';

    BEGIN -- Sub-bloco para capturar a exceção esperada
        INSERT INTO chefe_militar (faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao)
        VALUES ('Tenente', 'Líder Delta', 1, 1, 1); 
        RAISE EXCEPTION 'FALHA NO TESTE: Trigger 1 não impediu o 4º chefe militar.'; -- Não deve chegar aqui
    EXCEPTION
        WHEN raise_exception THEN -- Captura exceções levantadas por RAISE EXCEPTION
            IF SQLSTATE = 'P0004' OR SQLERRM LIKE '%máximo de 3 chefes militares%' THEN -- Verificando SQLSTATE P0004
                RAISE NOTICE ' -> SUCESSO: Trigger 1 impediu o 4º Chefe Militar como esperado. Erro: %', SQLERRM;
            ELSE
                RAISE NOTICE ' -> ERRO INESPERADO NO TESTE 1: Outra exceção ocorreu (SQLSTATE: %, SQLERRM: %)', SQLSTATE, SQLERRM;
                RAISE; -- Re-levanta a exceção inesperada
            END IF;
    END;

END $$;
ROLLBACK;
-- --------------------------------------
-- Teste do Trigger 1 concluído.
-- --------------------------------------


-- Testes para Trigger 2: fn_check_min_dois_grupos_por_conflito()
-- --------------------------------------
-- INICIANDO TESTES PARA TRIGGER 2: Mínimo 2 Grupos Ativos por Conflito
-- --------------------------------------
BEGIN; -- Transação SQL para este bloco de teste
DO $$
DECLARE
    v_grupos_ativos INTEGER;
BEGIN
    RAISE NOTICE 'Teste 2: Cenário para Conflito ID 4 ("Guerra dos Balcãs Ocidentais").';
    -- No script de povoamento, Grupos 21 e 5 participam ativamente.
    
    SELECT COUNT(DISTINCT id_grupo) INTO v_grupos_ativos
    FROM participa_grupo pg
    WHERE pg.id_conflito = 4 AND pg.data_de_saida IS NULL;
    RAISE NOTICE ' -> Grupos ativos no Conflito ID 4 antes do delete: % (Esperado: 2)', v_grupos_ativos;

    RAISE NOTICE ' -> Tentando remover a participação do Grupo ID 5 do Conflito ID 4...';
    -- Se removermos o grupo 5, o conflito 4 ficará com apenas 1 grupo ativo (grupo 21).
    BEGIN -- Sub-bloco para capturar a exceção esperada
        DELETE FROM participa_grupo 
        WHERE id_conflito = 4 AND id_grupo = 5 AND data_de_incorporacao = '2023-02-01'; 
        RAISE EXCEPTION 'FALHA NO TESTE: Trigger 2 não impediu a remoção do grupo.'; -- Não deve chegar aqui
    EXCEPTION
        WHEN raise_exception THEN
             IF SQLSTATE = 'P0001' OR SQLERRM LIKE '%pelo menos dois grupos armados participando ativamente%' THEN -- Verificando SQLSTATE P0001
                RAISE NOTICE ' -> SUCESSO: Trigger 2 impediu a remoção do grupo como esperado. Erro: %', SQLERRM;
            ELSE
                RAISE NOTICE ' -> ERRO INESPERADO NO TESTE 2: Outra exceção ocorreu (SQLSTATE: %, SQLERRM: %)', SQLSTATE, SQLERRM;
                RAISE; 
            END IF;
    END;
END $$;
ROLLBACK;
-- --------------------------------------
-- Teste do Trigger 2 concluído.
-- --------------------------------------

-- Testes para Trigger 3: fn_update_grupo_total_baixas()
-- --------------------------------------
-- INICIANDO TESTES PARA TRIGGER 3: Consistência de Baixas Totais do Grupo
-- --------------------------------------

-- Teste 3.1: INSERT em 'divisao'
BEGIN;
DO $$
DECLARE
    baixas_antes INTEGER;
    baixas_depois INTEGER;
BEGIN
    RAISE NOTICE 'Teste 3.1: INSERT em divisao';
    SELECT total_baixas INTO baixas_antes FROM grupo_armado WHERE id = 1;
    RAISE NOTICE ' -> Baixas do Grupo 1 ANTES: %', baixas_antes;
    
    INSERT INTO divisao (id, id_grupo, barcos, homens, tanques, avioes, baixas) 
    VALUES (1001, 1, 1, 100, 5, 1, 50); -- Nova divisão para Grupo 1 com 50 baixas
    RAISE NOTICE ' -> Divisão ID 1001 (Grupo 1) inserida com 50 baixas.';
    
    SELECT total_baixas INTO baixas_depois FROM grupo_armado WHERE id = 1;
    RAISE NOTICE ' -> Baixas do Grupo 1 DEPOIS: %', baixas_depois;
    IF baixas_depois = baixas_antes + 50 THEN
        RAISE NOTICE '   -> SUCESSO: total_baixas atualizado corretamente.';
    ELSE
        RAISE NOTICE '   -> FALHA: total_baixas NÃO atualizado corretamente. Esperado: %, Obtido: %', baixas_antes + 50, baixas_depois;
    END IF;
END $$;
ROLLBACK;

-- Teste 3.2: UPDATE de 'baixas' em 'divisao'
BEGIN;
DO $$
DECLARE
    baixas_grupo_antes INTEGER;
    baixas_divisao_antes INTEGER;
    baixas_grupo_depois INTEGER;
    baixas_divisao_depois INTEGER;
BEGIN
    RAISE NOTICE E'\nTeste 3.2: UPDATE de baixas em divisao';
    SELECT total_baixas INTO baixas_grupo_antes FROM grupo_armado WHERE id = 1;
    SELECT baixas INTO baixas_divisao_antes FROM divisao WHERE id = 1 AND id_grupo = 1;
    RAISE NOTICE ' -> Baixas do Grupo 1 ANTES: %. Baixas da Divisão 1 (Grupo 1) ANTES: %', baixas_grupo_antes, baixas_divisao_antes;
    
    UPDATE divisao SET baixas = baixas + 25 WHERE id = 1 AND id_grupo = 1; 
    RAISE NOTICE ' -> Baixas da Divisão 1 (Grupo 1) aumentadas em 25.';
    
    SELECT total_baixas INTO baixas_grupo_depois FROM grupo_armado WHERE id = 1;
    SELECT baixas INTO baixas_divisao_depois FROM divisao WHERE id = 1 AND id_grupo = 1;
    RAISE NOTICE ' -> Baixas do Grupo 1 DEPOIS: %. Baixas da Divisão 1 (Grupo 1) DEPOIS: %', baixas_grupo_depois, baixas_divisao_depois;
    IF baixas_grupo_depois = baixas_grupo_antes + 25 THEN
        RAISE NOTICE '   -> SUCESSO: total_baixas atualizado corretamente.';
    ELSE
        RAISE NOTICE '   -> FALHA: total_baixas NÃO atualizado corretamente. Esperado: %, Obtido: %', baixas_grupo_antes + 25, baixas_grupo_depois;
    END IF;
END $$;
ROLLBACK;

-- Teste 3.3: DELETE em 'divisao'
BEGIN;
DO $$
DECLARE
    baixas_grupo_antes INTEGER;
    baixas_divisao_deletada INTEGER;
    baixas_grupo_depois INTEGER;
BEGIN
    RAISE NOTICE E'\nTeste 3.3: DELETE em divisao';
    SELECT total_baixas INTO baixas_grupo_antes FROM grupo_armado WHERE id = 1;
    SELECT baixas INTO baixas_divisao_deletada FROM divisao WHERE id = 2 AND id_grupo = 1; 
    RAISE NOTICE ' -> Baixas do Grupo 1 ANTES: %. Baixas da Divisão 2 (Grupo 1) a ser deletada: %', baixas_grupo_antes, baixas_divisao_deletada;

    -- Precisa limpar dependências em chefe_militar antes de deletar divisão
    DELETE FROM chefe_militar WHERE id_divisao = 2 AND id_grupo_armado_divisao = 1;
    RAISE NOTICE '   -> Dependência em chefe_militar para Divisão 2 (Grupo 1) removida (se existia).';
    
    DELETE FROM divisao WHERE id = 2 AND id_grupo = 1; 
    RAISE NOTICE ' -> Divisão 2 (Grupo 1) deletada.';
    
    SELECT total_baixas INTO baixas_grupo_depois FROM grupo_armado WHERE id = 1;
    RAISE NOTICE ' -> Baixas do Grupo 1 DEPOIS: %', baixas_grupo_depois;
    IF baixas_grupo_depois = baixas_grupo_antes - baixas_divisao_deletada THEN
        RAISE NOTICE '   -> SUCESSO: total_baixas atualizado corretamente.';
    ELSE
        RAISE NOTICE '   -> FALHA: total_baixas NÃO atualizado corretamente. Esperado: %, Obtido: %', baixas_grupo_antes - baixas_divisao_deletada, baixas_grupo_depois;
    END IF;
END $$;
ROLLBACK;

-- Teste 3.4: UPDATE de 'id_grupo' em 'divisao' (mover divisão)
BEGIN;
DO $$
DECLARE
    baixas_grupo1_antes INTEGER;
    baixas_grupo2_antes INTEGER;
    baixas_divisao_movida INTEGER;
    baixas_grupo1_depois INTEGER;
    baixas_grupo2_depois INTEGER;
BEGIN
    RAISE NOTICE E'\nTeste 3.4: UPDATE de id_grupo em divisao (mover divisão)';
    SELECT total_baixas INTO baixas_grupo1_antes FROM grupo_armado WHERE id = 1;
    SELECT total_baixas INTO baixas_grupo2_antes FROM grupo_armado WHERE id = 2;
    SELECT baixas INTO baixas_divisao_movida FROM divisao WHERE id = 1 AND id_grupo = 1;
    RAISE NOTICE ' -> Baixas Grupo 1 ANTES: %. Baixas Grupo 2 ANTES: %. Baixas Divisão 1 (Grupo 1) a ser movida: %', baixas_grupo1_antes, baixas_grupo2_antes, baixas_divisao_movida;

    -- Precisa limpar/atualizar dependências em chefe_militar antes de mover divisão
    -- (Chefe com id_lider_politico = 'Alistair Vance', id_grupo_lider_politico = 1 comanda div(1,1))
    -- Se o schema tiver UNIQUE (nome_lider_politico, id_grupo_lider_politico) na FK de chefe_militar,
    -- e não tiver um líder para o grupo 2, esta parte pode precisar de ajuste ou o chefe precisa ser removido.
    -- Assumindo que 'Alistair Vance' não lidera o grupo 2 para evitar conflito na UNIQUE de chefe_militar.
    -- Vamos remover o chefe associado à divisão que está sendo movida.
    DELETE FROM chefe_militar WHERE id_divisao = 1 AND id_grupo_armado_divisao = 1;
    RAISE NOTICE '   -> Dependência em chefe_militar para Divisão 1 (Grupo 1) removida (se existia).';
    
    UPDATE divisao SET id_grupo = 2 WHERE id = 1 AND id_grupo = 1; 
    RAISE NOTICE ' -> Divisão 1 (originalmente do Grupo 1) movida para o Grupo 2.';
    
    SELECT total_baixas INTO baixas_grupo1_depois FROM grupo_armado WHERE id = 1;
    SELECT total_baixas INTO baixas_grupo2_depois FROM grupo_armado WHERE id = 2;
    RAISE NOTICE ' -> Baixas Grupo 1 DEPOIS: %. Baixas Grupo 2 DEPOIS: %', baixas_grupo1_depois, baixas_grupo2_depois;
    
    IF baixas_grupo1_depois = baixas_grupo1_antes - baixas_divisao_movida AND baixas_grupo2_depois = baixas_grupo2_antes + baixas_divisao_movida THEN
        RAISE NOTICE '   -> SUCESSO: total_baixas atualizado corretamente para ambos os grupos.';
    ELSE
        RAISE NOTICE '   -> FALHA: total_baixas NÃO atualizado corretamente. G1 Esperado: %, G1 Obtido: %. G2 Esperado: %, G2 Obtido: %', baixas_grupo1_antes - baixas_divisao_movida, baixas_grupo1_depois, baixas_grupo2_antes + baixas_divisao_movida, baixas_grupo2_depois;
    END IF;
END $$;
ROLLBACK;
-- --------------------------------------
-- Teste do Trigger 3 concluído.
-- --------------------------------------

-- Testes para Trigger 4: fn_set_numero_divisao_no_grupo()
-- Pré-requisito: A coluna 'numero_divisao_no_grupo' e a constraint UNIQUE(id_grupo, numero_divisao_no_grupo)
-- devem existir na tabela 'divisao'.
-- --------------------------------------
-- INICIANDO TESTES PARA TRIGGER 4: Geração de Número Sequencial de Divisão
-- --------------------------------------
BEGIN; -- Transação SQL para este bloco de teste
DO $$
DECLARE
    v_num_div_grupo INTEGER;
BEGIN
    RAISE NOTICE 'Teste 4.1: INSERT em divisao sem numero_divisao_no_grupo (assumindo coluna e constraint existem)';
    -- Limpar divisões do grupo 1 para um teste limpo de sequência
    DELETE FROM chefe_militar WHERE id_grupo_armado_divisao = 1; 
    DELETE FROM divisao WHERE id_grupo = 1;
    RAISE NOTICE ' -> Divisões do Grupo 1 limpas para o teste de sequência.';

    INSERT INTO divisao (id, id_grupo, barcos, homens, tanques, avioes, baixas) 
    VALUES (101, 1, 1, 10, 1, 0, 10); 
    SELECT numero_divisao_no_grupo INTO v_num_div_grupo FROM divisao WHERE id_grupo = 1 AND id = 101;
    RAISE NOTICE ' -> Divisão 101 (Grupo 1) inserida. numero_divisao_no_grupo: % (Esperado: 1)', v_num_div_grupo;
     IF v_num_div_grupo != 1 THEN RAISE NOTICE '   -> FALHA NO TESTE 4.1: Sequencial não é 1.'; END IF;


    INSERT INTO divisao (id, id_grupo, barcos, homens, tanques, avioes, baixas) 
    VALUES (102, 1, 2, 20, 2, 0, 20); 
    SELECT numero_divisao_no_grupo INTO v_num_div_grupo FROM divisao WHERE id_grupo = 1 AND id = 102;
    RAISE NOTICE ' -> Divisão 102 (Grupo 1) inserida. numero_divisao_no_grupo: % (Esperado: 2)', v_num_div_grupo;
     IF v_num_div_grupo != 2 THEN RAISE NOTICE '   -> FALHA NO TESTE 4.1: Sequencial não é 2.'; END IF;

    RAISE NOTICE E'\nTeste 4.2: INSERT em divisao especificando numero_divisao_no_grupo (trigger não deve sobrescrever)';
    INSERT INTO divisao (id, id_grupo, numero_divisao_no_grupo, barcos, homens, tanques, avioes, baixas) 
    VALUES (103, 1, 10, 3, 30, 3, 0, 30); 
    SELECT numero_divisao_no_grupo INTO v_num_div_grupo FROM divisao WHERE id_grupo = 1 AND id = 103;
    RAISE NOTICE ' -> Divisão 103 (Grupo 1) inserida com numero_divisao_no_grupo = 10. Obtido: % (Esperado: 10)', v_num_div_grupo;
    IF v_num_div_grupo != 10 THEN RAISE NOTICE '   -> FALHA NO TESTE 4.2: Valor especificado não mantido.'; END IF;

    -- Teste de violação da constraint UNIQUE (id_grupo, numero_divisao_no_grupo)
    RAISE NOTICE E'\nTeste 4.3: Tentando inserir numero_divisao_no_grupo duplicado (deve falhar pela constraint UNIQUE)';
    BEGIN
        INSERT INTO divisao (id, id_grupo, numero_divisao_no_grupo, barcos, homens, tanques, avioes, baixas) 
        VALUES (104, 1, 2, 4, 40, 4, 0, 40); -- Tentando usar numero 2 novamente para grupo 1
        RAISE EXCEPTION 'FALHA NO TESTE: Constraint UNIQUE(id_grupo, numero_divisao_no_grupo) não impediu duplicata.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE ' -> SUCESSO: Constraint UNIQUE impediu numero_divisao_no_grupo duplicado como esperado. Erro: %', SQLERRM;
        WHEN OTHERS THEN
            RAISE NOTICE ' -> ERRO INESPERADO NO TESTE 4.3: Outra exceção ocorreu (SQLSTATE: %, SQLERRM: %)', SQLSTATE, SQLERRM;
            RAISE;
    END;

END $$;
ROLLBACK;
-- --------------------------------------
-- Teste do Trigger 4 concluído.
-- --------------------------------------

-- --------------------------------------
-- Todos os testes de triggers concluídos.
-- --------------------------------------
DO $$
BEGIN
    RAISE NOTICE 'Todos os testes de triggers concluídos.';
END $$;

