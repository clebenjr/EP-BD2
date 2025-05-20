from flask import Flask, jsonify
from bd_connection import Banco

app = Flask(__name__)

@app.route('/')
def index():
    bd = Banco()
    
    bd.close()
    return "oi"

if __name__ == '__main__':
    app.run(debug=True)
