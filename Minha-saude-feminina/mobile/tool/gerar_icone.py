"""Gera os PNGs do ícone do app a partir da marca (mesmo desenho do favicon do painel).

Uso:  python tool/gerar_icone.py   (depois: dart run flutter_launcher_icons)
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROSA = (184, 30, 77, 255)        # #B81E4D
ROSA_CLARO = (252, 217, 229, 255)  # #FCD9E5
TAMANHO = 1024
ESCALA = 4  # desenha maior e reduz, para bordas suaves

destino = Path(__file__).resolve().parent.parent / 'assets' / 'icon'
destino.mkdir(parents=True, exist_ok=True)


def cruz(desenho, centro, comprimento, espessura, cor):
    meio, raio = comprimento / 2, espessura / 2
    cx, cy = centro
    desenho.rounded_rectangle((cx - raio, cy - meio, cx + raio, cy + meio), radius=raio, fill=cor)
    desenho.rounded_rectangle((cx - meio, cy - raio, cx + meio, cy + raio), radius=raio, fill=cor)


def gerar(nome, fundo, proporcao):
    grande = TAMANHO * ESCALA
    imagem = Image.new('RGBA', (grande, grande), fundo)
    desenho = ImageDraw.Draw(imagem)
    comprimento = grande * proporcao
    cruz(desenho, (grande / 2, grande / 2), comprimento, comprimento * 4 / 18, ROSA_CLARO)
    imagem.resize((TAMANHO, TAMANHO), Image.LANCZOS).save(destino / nome)


# Ícone completo (iOS, web e Android antigo): fundo rosa preenchendo o quadrado.
gerar('icone.png', ROSA, 0.5)
# Primeiro plano do ícone adaptativo do Android: só a cruz, dentro da área segura.
gerar('icone_frente.png', (0, 0, 0, 0), 0.36)
print(f'Ícones gerados em {destino}')
