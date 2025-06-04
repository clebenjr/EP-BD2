from flask import Flask, jsonify, render_template
from bd_connection import Banco
from pathlib import Path

FRONTEND_DIR = Path(__file__).resolve().parents[2] / 'frontend' / 'src'

app = Flask(__name__, template_folder=FRONTEND_DIR, static_folder=FRONTEND_DIR / 'static')
bd = Banco()

@app.route('/')
@app.route('/index')
def index():
    grafico = bd.busca_grafico()
    traficantes_e_grupos = bd.busca_traficantes_e_grupos_armados()
    maiores_conflitos = bd.busca_maiores_conflitos()
    organizacoes_mediadoras = bd.busca_organizacoes_mediadoras()
    grupos_armados = bd.busca_grupos_armados()
    pais = bd.busca_pais()
    return render_template('index.html',
                            grafico=grafico,
                            traficantes_e_grupos=traficantes_e_grupos,
                            maiores_conflitos=maiores_conflitos,
                            organizacoes_mediadoras=organizacoes_mediadoras,
                            grupos_armados=grupos_armados,
                            pais=pais)

@app.route('/cadastrar')
@app.route('/cadastrar.html')
def cadastrar():
    return render_template('cadastrar.html')



if __name__ == '__main__':
    app.run(debug=True)
