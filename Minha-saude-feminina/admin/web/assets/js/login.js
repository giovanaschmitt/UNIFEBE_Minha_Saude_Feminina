/* =============================================================================
   login.js — entrada na gestão
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  if (Auth.autenticado()) {
    location.href = destino();
    return;
  }

  document.getElementById('dicaModo').textContent = {
    demo: 'Modo demonstração: qualquer e-mail e senha entram.',
    api: 'Autenticando pela API da gestão.',
    firebase: 'Autenticando pelo Firebase.',
  }[AUTH_CONFIG.modo] || '';

  document.getElementById('verSenha').onclick = alternarSenha;
  document.getElementById('formLogin').addEventListener('submit', entrar);
});

function destino() {
  const proximo = parametroUrl('proximo');
  return /^[\w.-]+\.html$/.test(proximo || '') ? proximo : 'index.html';
}

function alternarSenha() {
  const campo = document.getElementById('senha');
  const mostrando = campo.type === 'text';
  campo.type = mostrando ? 'password' : 'text';
  const botao = document.getElementById('verSenha');
  botao.setAttribute('aria-label', mostrando ? 'Mostrar senha' : 'Ocultar senha');
  botao.textContent = mostrando ? '👁' : '🙈';
  campo.focus();
}

async function entrar(evento) {
  evento.preventDefault();

  const email = document.getElementById('email').value.trim();
  const senha = document.getElementById('senha').value;

  if (!email || !senha) {
    avisar('Preencha e-mail e senha.', 'erro');
    return;
  }

  const botao = document.getElementById('botaoEntrar');
  botao.disabled = true;
  botao.textContent = 'Entrando…';

  try {
    await Auth.entrar(email, senha);
    location.href = destino();
  } catch (erro) {
    avisar(erro.message, 'erro');
    document.getElementById('senha').value = '';
    document.getElementById('senha').focus();
    botao.disabled = false;
    botao.textContent = 'Entrar';
  }
}
