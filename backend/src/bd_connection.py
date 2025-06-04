import psycopg2
import os
from dotenv import load_dotenv
from pathlib import Path

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
    
    def close(self):
        self.cur.close()
        self.conn.close()
    