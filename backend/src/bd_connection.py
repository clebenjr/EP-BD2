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
        

    
    def busca(self):
        self.cur.execute('SELECT * FROM teste LIMIT 10;')  # Substitua por sua tabela real
        rows = self.cur.fetchall()
        return rows
    
    def close(self):
        self.cur.close()
        self.conn.close()
    