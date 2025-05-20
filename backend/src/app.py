from flask import Flask, jsonify
import psycopg2
import os
from dotenv import load_dotenv

# Carrega variáveis do arquivo .env
load_dotenv()

# Inicializa o app Flask
app = Flask(__name__)

# Conecta ao banco PostgreSQL usando as variáveis do .env
""" conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD")
) """

@app.route('/')
def index():
    #cur = conn.cursor()
    #cur.execute('SELECT * FROM sua_tabela LIMIT 10;')  # Substitua por sua tabela real
    #rows = cur.fetchall()
    #cur.close()
    return "<h1>oi</h1>"

if __name__ == '__main__':
    app.run(debug=True)
