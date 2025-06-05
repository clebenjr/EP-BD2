-- Define o schema a ser utilizado
SET search_path TO ep2_bd2;

-- 1. Trigger: Uma divisão é dirigida por três chefes militares como máximo.
-- Pré-requisito: A tabela chefe_militar referencia divisao(id, id_grupo)
-- através das colunas id_divisao e id_grupo_armado_divisao.
CREATE OR REPLACE FUNCTION fn_check_max_tres_chefes_por_divisao()
RETURNS TRIGGER AS $$
DECLARE
    chefe_count INTEGER;
BEGIN
    -- As colunas NEW.id_divisao e NEW.id_grupo_armado_divisao são NOT NULL conforme o schema.
    -- A lógica de contagem de chefes é executada diretamente.
    
    SELECT COUNT(*) INTO chefe_count
    FROM ep2_bd2.chefe_militar cm
    WHERE cm.id_divisao = NEW.id_divisao  -- Corrigido de id_da_divisao
      AND cm.id_grupo_armado_divisao = NEW.id_grupo_armado_divisao -- Corrigido de id_grupo_da_divisao
      AND (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND cm.id != NEW.id)); 
      -- Se for UPDATE, não conta o próprio chefe que está sendo atualizado,
      -- caso ele já estivesse nessa divisão.

    IF chefe_count >= 3 THEN
        RAISE EXCEPTION 'Operação inválida: A divisão ID % (do Grupo ID %) já possui o máximo de 3 chefes militares.',
            NEW.id_divisao, NEW.id_grupo_armado_divisao
        USING ERRCODE = 'P0004', HINT = 'Uma divisão não pode ter mais de 3 chefes.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_insert_update_chefe_militar_max_chefes
BEFORE INSERT OR UPDATE OF id_divisao, id_grupo_armado_divisao ON ep2_bd2.chefe_militar -- Colunas corrigidas
FOR EACH ROW
EXECUTE FUNCTION fn_check_max_tres_chefes_por_divisao();

-- 2. Trigger: Em um conflito armado participam como mínimo dois grupos armados (ativamente).
CREATE OR REPLACE FUNCTION fn_check_min_dois_grupos_por_conflito()
RETURNS TRIGGER AS $$
DECLARE
    grupo_count INTEGER;
BEGIN
    SELECT COUNT(DISTINCT id_grupo) INTO grupo_count -- Usando DISTINCT
    FROM ep2_bd2.participa_grupo
    WHERE id_conflito = OLD.id_conflito
      AND data_de_saida IS NULL; 

    IF grupo_count < 2 THEN
        RAISE EXCEPTION 'Operação inválida: O conflito ID % deve ter pelo menos dois grupos armados participando ativamente. Após esta operação, teria % grupo(s) ativo(s).',
            OLD.id_conflito, grupo_count
        USING ERRCODE = 'P0001', HINT = 'Um conflito deve manter ao menos 2 grupos armados participando ativamente.';
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
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE ep2_bd2.grupo_armado
        SET total_baixas = total_baixas + NEW.baixas
        WHERE id = NEW.id_grupo;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE ep2_bd2.grupo_armado
        SET total_baixas = total_baixas - OLD.baixas
        WHERE id = OLD.id_grupo;

    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.id_grupo IS DISTINCT FROM NEW.id_grupo THEN
            UPDATE ep2_bd2.grupo_armado
            SET total_baixas = total_baixas - OLD.baixas
            WHERE id = OLD.id_grupo;
            UPDATE ep2_bd2.grupo_armado
            SET total_baixas = total_baixas + NEW.baixas
            WHERE id = NEW.id_grupo;
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
-- Pré-requisito: A coluna 'id' existe na tabela 'divisao'
-- e existe uma constraint UNIQUE(id_grupo, id) nela.
CREATE OR REPLACE FUNCTION fn_set_id()
RETURNS TRIGGER AS $$
DECLARE
    next_seq INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Em cenários de alta concorrência, considerar SELECT ... FOR UPDATE.
        SELECT COALESCE(MAX(id), 0) + 1 INTO next_seq
        FROM ep2_bd2.divisao
        WHERE id_grupo = NEW.id_grupo;
        
        NEW.id := next_seq; -- Preenche a coluna correta
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_insert_divisao_set_seq_num
BEFORE INSERT ON ep2_bd2.divisao
FOR EACH ROW
WHEN (NEW.id IS NULL) -- Condição baseada na coluna correta
EXECUTE FUNCTION fn_set_id();

