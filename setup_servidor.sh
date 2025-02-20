#!/bin/bash

# Atualiza o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instala dependências necessárias
echo "Instalando dependências..."
sudo apt install -y python3 python3-pip tesseract-ocr libtesseract-dev git

# Instala bibliotecas do Python
echo "Instalando bibliotecas do Python..."
pip3 install Flask pytesseract Pillow requests opencv-python-headless pyautogui

# Criação de arquivos do servidor
echo "Criando arquivos do servidor..."

cat <<EOL > ~/Desktop/servidor/app.py
from flask import Flask, request, jsonify
import pytesseract
from PIL import Image
import io
import base64
from model import BettingAI
from database import init_db

app = Flask(__name__)

# Inicializa o database
init_db()

# Inicializa a IA de Apostas
betting_ai = BettingAI()

@app.route('/process_carta', methods=['POST'])
def process_carta():
    data = request.json
    image_data = base64.b64decode(data['image'])
    image = Image.open(io.BytesIO(image_data))
    texto = pytesseract.image_to_string(image, lang='por')

    # Mais lógica para processar a carta ...

    return jsonify({'status': 'success'})

@app.route('/previsao', methods=['GET'])
def previsao():
    return jsonify(betting_ai.prever_vencedor())

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
EOL

cat <<EOL > ~/Desktop/servidor/model.py
class Carta:
    def __init__(self, valor, naipe):
        self.valor = valor
        self.naipe = naipe

class BettingAI:
    def __init__(self):
        self.historico_cartas = []

    def atualizar_estado(self, valor, naipe):
        carta = Carta(valor, naipe)
        self.historico_cartas.append(carta)

    def prever_vencedor(self):
        return {"proxima_vitoria": "Jogador X", "probabilidade": "75%"}
EOL

cat <<EOL > ~/Desktop/servidor/database.py
import sqlite3

def init_db():
    conn = sqlite3.connect('cartas.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS resultados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            valor INTEGER,
            naipe TEXT
        )
    ''')
    conn.commit()
    conn.close()

def save_result(valor, naipe):
    conn = sqlite3.connect('cartas.db')
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO resultados (valor, naipe) VALUES (?, ?)
    ''', (valor, naipe))
    conn.commit()
    conn.close()
EOL

echo "Servidor configurado! Para iniciar o Flask, execute: python3 ~/Desktop/servidor/app.py"
