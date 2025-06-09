
SET search_path TO ep2_bd2;

CREATE OR REPLACE FUNCTION fn_check_max_tres_chefes_por_divisao()
RETURNS TRIGGER AS $$
DECLARE
    chefe_count INTEGER;
BEGIN

    
    SELECT COUNT(*) INTO chefe_count
    FROM ep2_bd2.chefe_militar cm
    WHERE cm.id_divisao = NEW.id_divisao 
      AND cm.id_grupo_armado_divisao = NEW.id_grupo_armado_divisao 
      AND (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND cm.id != NEW.id)); 

    IF chefe_count >= 3 THEN
        RAISE EXCEPTION 'Operação inválida: A divisão ID % (do Grupo ID %) já possui o máximo de 3 chefes militares.',
            NEW.id_divisao, NEW.id_grupo_armado_divisao
        USING ERRCODE = 'P0004', HINT = 'Uma divisão não pode ter mais de 3 chefes.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_insert_update_chefe_militar_max_chefes
BEFORE INSERT OR UPDATE OF id_divisao, id_grupo_armado_divisao ON ep2_bd2.chefe_militar 
FOR EACH ROW
EXECUTE FUNCTION fn_check_max_tres_chefes_por_divisao();


CREATE OR REPLACE FUNCTION fn_check_min_dois_grupos_por_conflito()
RETURNS TRIGGER AS $$
DECLARE
    grupo_count INTEGER;
BEGIN
    SELECT COUNT(DISTINCT id_grupo) INTO grupo_count 
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


CREATE OR REPLACE FUNCTION fn_set_id()
RETURNS TRIGGER AS $$
DECLARE
    next_seq INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT COALESCE(MAX(id), 0) + 1 INTO next_seq
        FROM ep2_bd2.divisao
        WHERE id_grupo = NEW.id_grupo;
        
        NEW.id := next_seq; 
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_insert_divisao_set_seq_num
BEFORE INSERT ON ep2_bd2.divisao
FOR EACH ROW
WHEN (NEW.id IS NULL)
EXECUTE FUNCTION fn_set_id();

