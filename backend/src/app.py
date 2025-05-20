from flask import Flask, jsonify
import psycopg2
import os
from dotenv import load_dotenv
from pathlib import Path

# Carrega variáveis do arquivo .env
dotenv_path = Path(__file__).resolve().parents[2] / '.env'
load_dotenv(dotenv_path=dotenv_path, override=True)

# Inicializa o app Flask
app = Flask(__name__)

# Conecta ao banco PostgreSQL usando as variáveis do .env
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    port=os.getenv("DB_PORT")
) 

@app.route('/')
def index():
    cur = conn.cursor()
    cur.execute('SELECT * FROM teste LIMIT 10;')  # Substitua por sua tabela real
    rows = cur.fetchall()
    cur.close()
    print(jsonify(rows))
    return jsonify(rows)

if __name__ == '__main__':
    app.run(debug=True)
