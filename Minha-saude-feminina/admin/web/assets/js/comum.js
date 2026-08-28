/* =============================================================================
   comum.js — cabeçalho, avisos e utilitários usados por todas as telas
   ========================================================================== */

/* ------------------------------------------------------------- cabeçalho --- */

function montarCabecalho(telaAtual) {
  const itens = [
    { id: 'artigos', rotulo: 'Artigos', href: 'index.html' },
    { id: 'categorias', rotulo: 'Categorias', href: 'categorias.html' },
  ];
  const temAuth = typeof Auth !== 'undefined';
  const sessao = temAuth ? Auth.sessao() : null;
 
  document.getElementById('cabecalho').innerHTML = `
    <div class="container py-3 d-flex align-items-center justify-content-between flex-wrap gap-2">
      <a class="marca d-flex align-items-center gap-2" href="index.html">Minha Saúde Feminina <span>💜</span></a>
      <nav class="d-flex align-items-center gap-1 flex-wrap">
        ${itens.map((i) => `<a class="nav-link ${i.id === telaAtual ? 'ativo' : ''}" href="${i.href}">${i.rotulo}</a>`).join('')}
        <div class="usuario">
          <button class="btn btn-sair" type="button" id="botaoSair" title="Encerrar a sessão">
            <span aria-hidden="true">⏻</span> Sair
          </button>
        </div>
      </nav>
    </div>`;
 
  document.getElementById('botaoSair').onclick = sair;
 
}

/* ---------------------------------------------------------------- avisos --- */

function avisar(mensagem, tipo = 'sucesso') {
  const area = document.getElementById('avisos');
  if (!area) return;
  const caixa = document.createElement('div');
  caixa.className = `alerta alert alert-dismissible fade show ${tipo === 'erro' ? 'alerta-erro' : 'alerta-sucesso'}`;
  caixa.setAttribute('role', 'status');
  caixa.innerHTML = `${mensagem}<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Fechar"></button>`;
  area.appendChild(caixa);
  setTimeout(() => caixa.querySelector('.btn-close')?.click(), 6000);
}

function avisarNaProxima(mensagem, tipo = 'sucesso') {
  sessionStorage.setItem('aviso_pendente', JSON.stringify({ mensagem, tipo }));
}

function mostrarAvisoPendente() {
  const guardado = sessionStorage.getItem('aviso_pendente');
  if (!guardado) return;
  sessionStorage.removeItem('aviso_pendente');
  const { mensagem, tipo } = JSON.parse(guardado);
  avisar(mensagem, tipo);
}

function tratarErro(erro) {
  console.error(erro);
  avisar(erro.message || 'Não foi possível concluir a operação.', 'erro');
}

/* ----------------------------------------------------------- utilitários --- */

function escapar(texto) {
  const caixa = document.createElement('div');
  caixa.textContent = texto ?? '';
  return caixa.innerHTML;
}

function textoDeHtml(html) {
  const caixa = document.createElement('div');
  caixa.innerHTML = html || '';
  return caixa.textContent.replace(/\s+/g, ' ').trim();
}

function formatarData(iso) {
  if (!iso) return '—';
  const data = new Date(iso);
  if (Number.isNaN(data.getTime())) return iso;
  return data.toLocaleString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function parametroUrl(nome) {
  return new URLSearchParams(location.search).get(nome);
}

function esperar(milissegundos) {
  return new Promise((resolver) => setTimeout(resolver, milissegundos));
}

function sair() {
  if (!confirm('Encerrar a sessão e voltar para a tela de login?')) return;
  if (typeof Auth !== 'undefined') {
    Auth.sair();
  } else {
    location.href = 'login.html';
  }
}