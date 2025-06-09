from flask import Flask, render_template, request, flash, redirect, url_for
from bd_connection import Banco
from pathlib import Path
import os

FRONTEND_DIR = Path(__file__).resolve().parents[2] / 'frontend' / 'src'

app = Flask(__name__, template_folder=FRONTEND_DIR, static_folder=FRONTEND_DIR / 'static')
app.secret_key = os.getenv('SECRET_KEY')
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
        print("Cadastrando conflito")
        print(request.form.getlist('tipo'))
        id_conflito = bd.cadastrar_conflito(request.form['nome'], request.form['mortos'], request.form['feridos'])
        if id_conflito is None:
            return redirect(url_for('cadastrar_conflito'))
        tipos = request.form.getlist('tipo')
        descricoes = request.form.getlist('conflitos')
        for tipo, descricao in zip(tipos, descricoes):
            if tipo == 'materia-prima':
                res = bd.cadastrar_materia_prima(descricao, id_conflito)
            elif tipo == 'regiao':
                res = bd.cadastrar_regiao(descricao, id_conflito)
            elif tipo == 'religiao':
                res = bd.cadastrar_religiao(descricao, id_conflito)
            elif tipo == 'etnia':
                res = bd.cadastrar_etnia(descricao, id_conflito)
        if res is None:
            return redirect(url_for('cadastrar_divisao'))
        flash("Formulário enviado com sucesso!", "success")
        return redirect(url_for('cadastrar_divisao'))
    else:
        return render_template('cadastrar-conflito.html')


@app.route('/cadastrar/divisao', methods=['GET', 'POST'])
def cadastrar_divisao():
    if request.method == 'POST':
        print(request.form['barcos'])
        print("Adicionando divisão")
        res = bd.cadastrar_divisao(request.form['id_grupo'], request.form['barcos'], request.form['homens'], request.form['tanques'], request.form['avioes'], request.form['baixas'])
        if res is None:
            return redirect(url_for('cadastrar_divisao'))
        flash("Formulário enviado com sucesso!", "success")
        return redirect(url_for('cadastrar_divisao'))
    else:
        nomes_grupos = bd.busca_nomes_grupos()
        return render_template('cadastrar-divisao.html', nomes_grupos=nomes_grupos)
    

@app.route('/cadastrar/chefe', methods=['GET', 'POST'])
def cadastrar_chefe():
    if request.method == 'POST':
        print("Cadastrando chefe militar")
        lider_value = request.form['nome_lider']
        nome_lider_politico, nome_grupo_lider = lider_value.split('|')
        id_grupo_lider = bd.buscar_id_grupo_armado(nome_grupo_lider)

        divisao_value = request.form['id_divisao'] 
        id_divisao, nome_grupo_divisao = divisao_value.split('|')
        id_grupo_divisao_que_comanda = bd.buscar_id_grupo_armado(nome_grupo_divisao)
        res = bd.cadastrar_chefe_militar(
            request.form['faixas'],
            nome_lider_politico,
            id_grupo_lider,
            id_divisao,
            id_grupo_divisao_que_comanda
        )
        if res is None:
            return redirect(url_for('cadastrar_chefe'))
        flash("Formulário enviado com sucesso!", "success")
        return redirect(url_for('cadastrar_chefe'))
    else:
        nomes_divisoes = bd.buscar_nomes_divisoes()
        lideres_e_grupos = bd.buscar_lider_e_grupo()
        return render_template('cadastrar-chefes.html', nomes_divisoes=nomes_divisoes, lideres_e_grupos=lideres_e_grupos)


@app.route('/cadastrar/grupos', methods=['GET', 'POST'])
def cadastrar_grupos():
    if request.method == 'POST':
        print("Adicionando grupo militar")
        res = bd.cadastrar_grupo(request.form['nome'])
        if res is None:
            return redirect(url_for('cadastrar_grupos'))
        flash("Formulário enviado com sucesso!", "success")
        return redirect(url_for('cadastrar_grupos'))
    else:
        return render_template('cadastrar-grupos.html')
    

@app.route('/cadastrar/lideres', methods=['GET', 'POST'])
def cadastrar_lideres():
    if request.method == 'POST':
        print("Cadastrando líder")
        res = bd.cadastrar_lider(request.form['nome'], request.form['id_grupo'], request.form['descricao_apoio'])
        if res is None:
            return redirect(url_for('cadastrar_lideres'))
        flash("Formulário enviado com sucesso!", "success")
        return redirect(url_for('cadastrar_lideres'))
    else:
        nomes_grupos = bd.busca_nomes_grupos()
        return render_template('cadastrar-lideres.html', nomes_grupos=nomes_grupos)


if __name__ == '__main__':
    app.run(debug=True)
