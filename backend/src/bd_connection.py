import psycopg2
import os
from dotenv import load_dotenv
from pathlib import Path
from flask import flash



class Banco:
    def __init__(self):
        # Carrega variáveis do arquivo .env
        dotenv_path = Path(__file__).resolve().parents[2] / '.env'
        load_dotenv(dotenv_path=dotenv_path, override=True)

        self.conn = psycopg2.connect(
            host=os.getenv("DB_HOST"),
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            port=os.getenv("DB_PORT")
        ) 

        self.cur = self.conn.cursor()

        self.cur.execute("SET search_path TO ep2_bd2;")  
    
    @staticmethod
    def error_handler(f):
        def wrapper(self, *args, **kwargs):
            try:
                return f(self, *args, **kwargs)
            except psycopg2.Error as e:
                print(f"Database error: {e}")
                flash("Ocorreu um erro ao acessar o banco de dados. Por favor, tente novamente mais tarde.", "error")
                self.conn.rollback()
                self.cur.execute("SET search_path TO ep2_bd2;")  
                return None
            except Exception as e:
                print(f"An error occurred: {e}")
                flash("Ocorreu um erro inesperado. Por favor, tente novamente mais tarde.", "error")
                self.conn.rollback()
                self.cur.execute("SET search_path TO ep2_bd2;")  
                return None
        return wrapper

    
    def busca_grafico(self):
        self.cur.execute("""SELECT
        'Por Região' AS TipoDeConflito,
        COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
        FROM
            Regioes_conflito
        UNION ALL
        SELECT
            'Por Matéria Prima' AS TipoDeConflito,
            COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
        FROM
            Materias_Primas_conflito -- Presumindo que o nome da tabela seja "Materias_Primas" ou similar sem acentos/espaços. Ajuste se necessário.
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
            Etnias_conflito;
        """)  
        rows = self.cur.fetchall()
        return rows
    
    def busca_traficantes_e_grupos_armados(self):
        self.cur.execute("""
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
                    """)
        rows = self.cur.fetchall()
        return rows
    
    def busca_maiores_conflitos(self):
        self.cur.execute("""
                        SELECT
                            nome,
                            numero_de_mortos, -- Se o nome da coluna tiver espaços, é preciso usar aspas (ou o delimitador específico do seu SGBD, como colchetes [] ou crases ``)
                            numero_de_feridos
                        FROM
                            conflito
                        ORDER BY
                            numero_de_mortos DESC
                        LIMIT 5;
                    """)
        rows = self.cur.fetchall()
        return rows
    
    def busca_organizacoes_mediadoras(self):
        self.cur.execute("""
                        SELECT
                            OM.nome AS NomeOrganizacao,
                            OM.tipo as Tipo,
                            COUNT(PO.Id_Organizacao) AS NumeroDeMediacoes
                        FROM
                            participa_organizacao PO
                        INNER JOIN
                            organizacao_mediadora OM ON PO.id_organizacao = OM.id
                        GROUP BY
                            OM.nome, OM.tipo -- ou PO.Id_Organizacao e OM.Nome, mas agrupar pelo nome é suficiente se o nome for único.
                        ORDER BY
                            NumeroDeMediacoes DESC
                        LIMIT 5;
                    """)
        rows = self.cur.fetchall()
        return rows
    
    def busca_grupos_armados(self):
        self.cur.execute("""
                        SELECT
                            GA.nome AS NomeGrupoArmado,
                            SUM(F.Quantidade_fornecida) AS TotalArmasFornecidas
                        FROM
                            fornece_arma_grupo F
                        INNER JOIN
                            grupo_armado GA ON F.id_grupo_armado = GA.id
                        GROUP BY
                            GA.nome -- ou GA.Id e GA.Nome, mas agrupar pelo nome é suficiente se o nome for único.
                        ORDER BY
                            TotalArmasFornecidas DESC
                        LIMIT 5;
                    """)
        rows = self.cur.fetchall()
        return rows
    
    def busca_pais(self):
        self.cur.execute("""
                        SELECT
                            A.nome_pais,
                            COUNT(DISTINCT R.id_conflito) AS NumeroDeConflitosReligiosos
                        FROM
                            afeta A
                        INNER JOIN
                            religioes_conflito R ON a.id_conflito = R.id_conflito
                        GROUP BY
                            A.nome_pais
                        ORDER BY
                            NumeroDeConflitosReligiosos DESC
                        LIMIT 1;
                    """)
        rows = self.cur.fetchall()
        return rows
    
    def cadastrar_grupo(self, nome):
        self.cur.execute("INSERT INTO grupo_armado (nome) VALUES (%s)", (nome,))
        self.conn.commit()
        return "Funcionou"
    
    def busca_nomes_grupos(self):
        self.cur.execute("SELECT id, nome FROM grupo_armado ORDER BY id;")
        rows = self.cur.fetchall()
        return rows
    
    def busca_nomes_lideres(self):
        self.cur.execute("select nome, id_grupo from lider_politico order by nome, id_grupo;")
        rows = self.cur.fetchall()
        return rows
    
    def buscar_nomes_divisoes(self):
        self.cur.execute("""select g.nome, d.id 
                            from divisao d join grupo_armado g on d.id_grupo = g.id
                            order by g.nome, d.id;
                         """)
        rows = self.cur.fetchall()
        return rows
    
    @error_handler
    def cadastrar_divisao(self, id_grupo, barcos, homens=0, tanques=0, avioes=0, baixas=0):
        self.cur.execute("INSERT INTO divisao (id_grupo, barcos, homens, tanques, avioes, baixas) VALUES (%s, %s, %s, %s, %s, %s)", (id_grupo, barcos, homens, tanques, avioes, baixas))
        self.conn.commit()
        return "Divisão cadastrada com sucesso"
    
    def cadastrar_lider(self, nome, id_grupo, descricao_apoio):
        self.cur.execute("INSERT INTO lider_politico (nome, id_grupo, descricao_apoio) VALUES (%s, %s, %s)", (nome, id_grupo, descricao_apoio))
        self.conn.commit()
        return "Líder cadastrado com sucesso"
    
    def cadastrar_conflito(self, nome, mortos, feridos):
        self.cur.execute("INSERT INTO conflito (nome, numero_de_mortos, numero_de_feridos) VALUES (%s, %s, %s) RETURNING id", (nome, mortos, feridos))
        conflito_id = self.cur.fetchone()[0]
        self.conn.commit()
        return conflito_id
    
    def buscar_lider_e_grupo(self):
        self.cur.execute("""
                         select lp.nome as NomeLider, ga.nome as NomeGrupo
                         from lider_politico lp
                         join grupo_armado ga on lp.id_grupo = ga.id
                         order by ga.nome, lp.nome;
                         """)
        rows = self.cur.fetchall()
        return rows
    
    def cadastrar_chefe_militar(self, faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao):
        self.cur.execute("""insert into chefe_militar 
                         (faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao) 
                         values (%s, %s, %s, %s, %s)""", 
                         (faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao))
        self.conn.commit()
        return "Chefe militar cadastrado com sucesso"
    
    def cadastrar_materia_prima(self, nome, id_conflito):
        self.cur.execute("INSERT INTO materias_primas_conflito (materia_prima, id_conflito) VALUES (%s, %s)", (nome, id_conflito))
        self.conn.commit()
        return "Matéria-prima cadastrada com sucesso"
    
    def cadastrar_regiao(self, nome, id_conflito):
        self.cur.execute("INSERT INTO regioes_conflito (regiao, id_conflito) VALUES (%s, %s)", (nome, id_conflito))
        self.conn.commit()
        return "Região cadastrada com sucesso"
    
    def cadastrar_religiao(self, nome, id_conflito):
        self.cur.execute("INSERT INTO religioes_conflito (religiao, id_conflito) VALUES (%s, %s)", (nome, id_conflito))
        self.conn.commit()
        return "Religião cadastrada com sucesso"
    
    def cadastrar_etnia(self, nome, id_conflito):
        self.cur.execute("INSERT INTO etnias_conflito (etnia, id_conflito) VALUES (%s, %s)", (nome, id_conflito))
        self.conn.commit()
        return "Etnia cadastrada com sucesso"

    def buscar_id_grupo_armado(self, nome_grupo):
        self.cur.execute("SELECT id FROM grupo_armado WHERE nome = %s", (nome_grupo,))
        row = self.cur.fetchone()
        if row:
            return row

    def close(self):
        self.cur.close()
        self.conn.close()
    