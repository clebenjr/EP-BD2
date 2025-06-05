- Define o schema a ser utilizado
SET search_path TO ep2_bd2;

-- 1. Trigger: Uma divisão é dirigida por três chefes militares como máximo.
-- Pré-requisito: O schema da tabela chefe_militar foi ajustado conforme sugerido acima,
-- permitindo que id_da_divisao e id_grupo_da_divisao sejam NULL e referenciem
-- a chave primária composta de divisao.
CREATE OR REPLACE FUNCTION fn_check_max_tres_chefes_por_divisao()
RETURNS TRIGGER AS $$
DECLARE
    chefe_count INTEGER;
BEGIN
    -- Verifica apenas se uma divisão está sendo atribuída ou alterada

    SELECT COUNT(*) INTO chefe_count
    FROM ep2_bd2.chefe_militar
    WHERE id_divisao = NEW.id_divisao AND id_grupo_armado_divisao = NEW.id_grupo_armado_divisao
        AND id != COALESCE(NEW.id, -1); -- Exclui o próprio chefe se for um UPDATE

        -- Se for INSERT, a contagem não inclui o NEW.
        -- Se for UPDATE, o COUNT acima já exclui o NEW.id (se existir).
        -- Portanto, a lógica é que chefe_count não pode ser >= 3.
        -- Se já existem 3, chefe_count será 3, e adicionar/mover um 4º é proibido.
        IF chefe_count >= 3 THEN
            RAISE EXCEPTION 'Operação inválida: A divisão ID % (Grupo ID %) já possui o máximo de 3 chefes militares.',
                NEW.id_divisao, NEW.id_grupo_armado_divisao
            USING ERRCODE = 'P0004', HINT = 'Uma divisão não pode ter mais de 3 chefes.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_insert_update_chefe_militar_max_chefes
BEFORE INSERT OR UPDATE OF id_da_divisao, id_grupo_da_divisao ON ep2_bd2.chefe_militar
FOR EACH ROW
EXECUTE FUNCTION fn_check_max_tres_chefes_por_divisao();

-- 2. Trigger: Em um conflito armado participam como mínimo dois grupos armados.
CREATE OR REPLACE FUNCTION fn_check_min_dois_grupos_por_conflito()
RETURNS TRIGGER AS $$
DECLARE
    grupo_count INTEGER;
BEGIN
    -- Após uma deleção, verifica se o conflito afetado ainda tem pelo menos 2 grupos.
    -- Esta lógica não impede a criação de um conflito com menos de 2 grupos,
    -- apenas a redução abaixo de 2 para um conflito que já existia com >= 2 grupos.
   SELECT COUNT(*) INTO grupo_count
    FROM ep2_bd2.participa_grupo
    WHERE id_conflito = OLD.id_conflito
      AND data_de_saida IS NULL; -- Adicionada condição para contar apenas grupos ativos

    IF grupo_count < 2 THEN
        RAISE EXCEPTION 'Operação inválida: O conflito ID % deve ter pelo menos dois grupos armados participando. Após esta operação, teria %.',
            OLD.id_conflito, grupo_count
        USING ERRCODE = 'P0001', HINT = 'Um conflito deve manter ao menos 2 grupos armados.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_delete_participa_grupo_min_grupos
AFTER DELETE ON ep2_bd2.participa_grupo
FOR EACH ROW
EXECUTE FUNCTION fn_check_min_dois_grupos_por_conflito();

-- 3. Trigger: Manter a consistência das baixas totais em cada grupo armado.
-- Pré-requisito: A coluna 'total_baixas' existe na tabela 'grupo_armado'.
CREATE OR REPLACE FUNCTION fn_update_grupo_total_baixas()
RETURNS TRIGGER AS $$
DECLARE
    v_old_id_grupo INTEGER;
    v_new_id_grupo INTEGER;
BEGIN
    -- Caso de INSERT na tabela divisao
    IF TG_OP = 'INSERT' THEN
        UPDATE ep2_bd2.grupo_armado
        SET total_baixas = total_baixas + NEW.baixas
        WHERE id = NEW.id_grupo;

    -- Caso de DELETE na tabela divisao
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE ep2_bd2.grupo_armado
        SET total_baixas = total_baixas - OLD.baixas
        WHERE id = OLD.id_grupo;

    -- Caso de UPDATE na tabela divisao
    ELSIF TG_OP = 'UPDATE' THEN
        -- Se o id_grupo da divisão mudou
        IF OLD.id_grupo IS DISTINCT FROM NEW.id_grupo THEN
            -- Subtrai baixas do grupo antigo
            UPDATE ep2_bd2.grupo_armado
            SET total_baixas = total_baixas - OLD.baixas
            WHERE id = OLD.id_grupo;
            -- Adiciona baixas ao novo grupo
            UPDATE ep2_bd2.grupo_armado
            SET total_baixas = total_baixas + NEW.baixas
            WHERE id = NEW.id_grupo;
        -- Se apenas as baixas mudaram (mesmo grupo)
        ELSIF OLD.baixas IS DISTINCT FROM NEW.baixas THEN
            UPDATE ep2_bd2.grupo_armado
            SET total_baixas = total_baixas - OLD.baixas + NEW.baixas
            WHERE id = NEW.id_grupo;
        END IF;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_insert_update_delete_divisao_baixas
AFTER INSERT OR UPDATE OF baixas, id_grupo OR DELETE ON ep2_bd2.divisao
FOR EACH ROW
EXECUTE FUNCTION fn_update_grupo_total_baixas();


-- 4. Trigger: Gerar e assegurar a sequencialidade do número de divisão dentro do grupo armado.
-- Pré-requisito: A coluna 'numero_divisao_no_grupo' e a constraint UNIQUE(id_grupo, numero_divisao_no_grupo)
-- existem na tabela 'divisao'.
CREATE OR REPLACE FUNCTION fn_set_numero_divisao_no_grupo()
RETURNS TRIGGER AS $$
DECLARE
    next_seq INTEGER;
BEGIN
    -- Este trigger só lida com a geração na inserção.
    -- Deleções podem criar "buracos" na sequência.
    -- Updates de id_grupo exigiriam lógica mais complexa para re-sequenciar.
    IF TG_OP = 'INSERT' THEN
        -- Bloqueia a tabela ou usa um mecanismo de bloqueio mais granular se alta concorrência for um problema.
        -- Para simplicidade, aqui calcula o próximo MAX.
        -- Em cenários de alta concorrência, uma sequence do PostgreSQL por grupo ou
        -- advisory locks podem ser considerados.
        SELECT COALESCE(MAX(id), 0) + 1 INTO next_seq
        FROM ep2_bd2.divisao
        WHERE id_grupo = NEW.id_grupo;
        -- Adicionar FOR UPDATE na query acima se houver transações concorrentes que possam causar problemas.
        -- Ex: FROM ep2_bd2.divisao WHERE id_grupo = NEW.id_grupo FOR UPDATE;
        -- Isso bloquearia as linhas do grupo específico.

        NEW.id := next_seq;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_insert_divisao_set_seq_num
BEFORE INSERT ON ep2_bd2.divisao
FOR EACH ROW
WHEN (NEW.numero_divisao_no_grupo IS NULL) -- Só executa se o número não for fornecido manualmente
EXECUTE FUNCTION fn_set_numero_divisao_no_grupo();
-- 5. Trigger: Atualizar o número de mortos no conflito quando um grupo participa.