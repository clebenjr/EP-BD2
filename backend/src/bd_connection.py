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
        

    
    def busca_tabela(self):
        self.cur.execute("""SELECT
        'Por Região' AS TipoDeConflito,
        COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
        FROM
            Regioes
        UNION ALL
        SELECT
            'Por Matéria Prima' AS TipoDeConflito,
            COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
        FROM
            Materias_Primas -- Presumindo que o nome da tabela seja "Materias_Primas" ou similar sem acentos/espaços. Ajuste se necessário.
        UNION ALL
        SELECT
            'Por Religião' AS TipoDeConflito,
            COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
        FROM
            religioes 
        UNION ALL
        SELECT
            'Por Etnia' AS TipoDeConflito,
            COUNT(DISTINCT id_conflito) AS NumeroDeConflitos
        FROM
            Etnias;
        """)  
        rows = self.cur.fetchall()
        return rows
    
    def close(self):
        self.cur.close()
        self.conn.close()
    