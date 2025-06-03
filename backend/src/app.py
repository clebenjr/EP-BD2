from flask import Flask, jsonify, render_template
from bd_connection import Banco
from pathlib import Path

FRONTEND_DIR = Path(__file__).resolve().parents[2] / 'frontend' / 'src'

app = Flask(__name__, template_folder=FRONTEND_DIR, static_folder=FRONTEND_DIR / 'static')

@app.route('/')
@app.route('/index')
def index():
    bd = Banco()
    print(bd.busca_tabela())
    bd.close()
    return render_template('index.html')

@app.route('/cadastrar')
def cadastrar():
    return render_template('cadastrar.html')



if __name__ == '__main__':
    app.run(debug=True)
