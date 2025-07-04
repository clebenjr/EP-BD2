# Trabalho de Banco de Dados 2 - EACH USP 2025 Sistemas de Informação

## Passo a Passo para Configuração e Execução

### 1. Clonar o Repositório
Para começar, clone o repositório do GitHub para sua máquina local. Execute o seguinte comando no terminal:
```bash
git clone https://github.com/clebenjr/EP-BD2.git
```


### 2. Navegar até o Diretório do Projeto
Entre no diretório do projeto clonado:
```bash
cd seu-repositorio
```

### 3. Criar um Ambiente Virtual (recomendado)

Crie um ambiente virtual para isolar as dependências do projeto:


```python -m venv venv```

#### Ative o ambiente virtual:

- Linux/macOS:


```
source venv/bin/activate
```

- Windows:

```
venv\\Scripts\\activate
```

Você saberá que o ambiente está ativado quando o nome dele aparecer no início da linha do terminal, assim:

```
(venv) $
```

### 4. Instalar Dependências
Certifique-se de que você tenha o `python` e o `pip` instalados. Em seguida, instale as dependências do projeto:

```bash
pip install -r requirements.txt
```

### 5. Configurar o Banco de Dados
Copie o arquivo `.env-example` e crie o arquivo `.env`. Após isso, substitua as informações do seu banco de dados postgres para configurar o banco de dados necessário para a aplicação.

```
cp .env-example .env
```


### 6. Crie o Banco de Dados
Execute os scripts sql, que estão na pasta `sqlscripts/` de criação de banco em ordem: `dbdefinition.sql`, `dbtriggers.sql`, `dbpopulate.sql`.

### 7. Executar a Aplicação
Inicie a aplicação com o comando:

```bash
python backend/src/app.py
```

### 8. Acessar a Aplicação
Abra o navegador e acesse o endereço `http://127.0.0.1:5000`.

Pronto! Agora você pode explorar a aplicação e o banco de dados desenvolvido para o trabalho da disciplina.