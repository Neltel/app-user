#!/bin/bash

# Atualiza o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instala dependências necessárias
echo "Instalando dependências..."
sudo apt install -y python3 python3-pip

# Instala bibliotecas do Python para o cliente
echo "Instalando bibliotecas do Python..."
pip3 install requests pyautogui Pillow pytesseract

# Criação de arquivos do cliente
echo "Criando arquivos do cliente..."

cat <<EOL > ~/Desktop/cliente/captura.py
import tkinter as tk
from tkinter import filedialog
import requests
import base64

# Função para capturar e enviar imagem
def capturar_imagem():
    arquivo = filedialog.askopenfilename()
    if arquivo:
        with open(arquivo, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
            response = requests.post('http://localhost:5000/process_carta', json={'image': encoded_string})
            print(response.json())

# Interface gráfica
root = tk.Tk()
btn = tk.Button(root, text="Capturar Imagem", command=capturar_imagem)
btn.pack()
root.mainloop()
EOL

echo "Cliente configurado! Para executar o cliente, execute: python3 ~/Desktop/cliente/captura.py"
