from flask import Flask, jsonify, render_template, request
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

@app.route('/cadastrar/conflito', methods=['GET', 'POST'])
def cadastrar_conflito():
    if request.method == 'POST':
        # Aqui você pode processar os dados do formulário
        # Por exemplo, salvar no banco de dados
        pass
    # Renderiza o template para cadastrar um conflito
    else:
        # Aqui você pode carregar dados necessários para o formulário, se necessário
        return render_template('cadastrar-conflito.html')


@app.route('/cadastrar/divisao', methods=['GET', 'POST'])
def cadastrar_divisao():
    if request.method == 'POST':
        print(request.form['barcos'])
        print("Adicionando divisão")
        bd.cadastrar_divisao(request.form['id_grupo'], request.form['barcos'], request.form['homens'], request.form['tanques'], request.form['avioes'], request.form['baixas'])
        return "Funcionou"
    else:
        nomes_grupos = bd.busca_nomes_grupos()
        return render_template('cadastrar-divisao.html', nomes_grupos=nomes_grupos)
    

@app.route('/cadastrar/chefe', methods=['GET', 'POST'])
def cadastrar_chefe():
    if request.method == 'POST':
        # Aqui você pode processar os dados do formulário
        # Por exemplo, salvar no banco de dados
        pass
    # Renderiza o template para cadastrar um conflito
    else:
        # Aqui você pode carregar dados necessários para o formulário, se necessário
        return render_template('cadastrar-chefes.html')


@app.route('/cadastrar/grupos', methods=['GET', 'POST'])
def cadastrar_grupos():
    if request.method == 'POST':
        print(request.form['nome'])
        print("Adicionando grupo militar")
        bd.cadastrar_grupo(request.form['nome'])
        return "funcionou"
    else:
        # Aqui você pode carregar dados necessários para o formulário, se necessário
        return render_template('cadastrar-grupos.html')
    

@app.route('/cadastrar/lideres', methods=['GET', 'POST'])
def cadastrar_lideres():
    if request.method == 'POST':
        # Aqui você pode processar os dados do formulário
        # Por exemplo, salvar no banco de dados
        pass
    # Renderiza o template para cadastrar um conflito
    else:
        nomes_grupos = bd.busca_nomes_grupos()
        return render_template('cadastrar-lideres.html', nomes_grupos=nomes_grupos)


if __name__ == '__main__':
    app.run(debug=True)
