/* =============================================================================
   painel.js — listagem e gestão dos artigos
   ========================================================================== */

let categorias = [];
let artigoParaExcluir = null;
let modalExcluir = null;

const filtros = { busca: '', categoria_id: '', situacao: '' };

document.addEventListener('DOMContentLoaded', iniciar);

async function iniciar() {
  if (!Auth.exigirSessao()) return;
  montarCabecalho('artigos');
  mostrarAvisoPendente();
  modalExcluir = new bootstrap.Modal(document.getElementById('modalExcluir'));

  document.getElementById('formFiltros').addEventListener('submit', (evento) => {
    evento.preventDefault();
    filtros.busca = document.getElementById('busca').value.trim();
    filtros.categoria_id = document.getElementById('categoria_id').value;
    filtros.situacao = document.getElementById('situacao').value;
    carregarArtigos();
  });

  document.getElementById('botaoLimpar').onclick = () => {
    document.getElementById('formFiltros').reset();
    Object.assign(filtros, { busca: '', categoria_id: '', situacao: '' });
    carregarArtigos();
  };

  document.getElementById('confirmarExclusao').onclick = confirmarExclusao;

  await carregarCategorias();
  await carregarArtigos();
}

async function carregarCategorias() {
  try {
    categorias = await Api.listarCategorias();
    const select = document.getElementById('categoria_id');
    categorias.forEach((c) => {
      select.insertAdjacentHTML('beforeend', `<option value="${c.id}">${c.emoji} ${escapar(c.nome)}</option>`);
    });
    document.getElementById('mCategorias').textContent = categorias.length;
  } catch (erro) {
    tratarErro(erro);
  }
}

async function carregarArtigos() {
  const area = document.getElementById('listagem');
  area.innerHTML = '<div class="vazio">Carregando artigos…</div>';
  try {
    const [filtrada, todos] = await Promise.all([
      Api.listarArtigos(filtros),
      Api.listarArtigos({}),
    ]);
    atualizarMetricas(todos.artigos);
    desenharListagem(filtrada.artigos);
  } catch (erro) {
    tratarErro(erro);
    area.innerHTML = `<div class="vazio">
        <p class="mb-2">Não foi possível carregar os artigos.</p>
        <p class="ajuda mb-3">${escapar(erro.message)}</p>
        <button class="btn btn-contorno" onclick="carregarArtigos()">Tentar de novo</button>
      </div>`;
  }
}

function atualizarMetricas(artigos) {
  const publicados = artigos.filter((a) => a.publicado).length;
  document.getElementById('mTotal').textContent = artigos.length;
  document.getElementById('mPublicados').textContent = publicados;
  document.getElementById('mRascunhos').textContent = artigos.length - publicados;
}

function desenharListagem(artigos) {
  const area = document.getElementById('listagem');

  if (artigos.length === 0) {
    area.innerHTML = `<div class="vazio">
        <p class="mb-3">Nenhum artigo encontrado com esses filtros.</p>
        <a class="btn btn-rosa" href="artigo.html">Criar um artigo</a>
      </div>`;
    return;
  }

  area.innerHTML = `
    <div class="table-responsive">
      <table class="table tabela-artigos align-middle">
        <thead>
          <tr style="height: 40px;">
            <th style="width: 46%">Artigo</th>
            <th>Categoria</th>
            <th style="width: 15%">Situação</th>
            <th>Atualizado</th>
            <th class="text-end">Ações</th>
          </tr>
        </thead>
        <tbody>${artigos.map(linha).join('')}</tbody>
      </table>
    </div>`;

  area.querySelectorAll('[data-publicar]').forEach((botao) => {
    botao.onclick = () => alternarPublicacao(Number(botao.dataset.publicar), botao.dataset.estado === '1');
  });
  area.querySelectorAll('[data-excluir]').forEach((botao) => {
    botao.onclick = () => pedirExclusao(Number(botao.dataset.excluir), botao.dataset.titulo);
  });
}

function linha(artigo) {
  const capa = artigo.capa_url
    ? `<img src="${escapar(artigo.capa_url)}" alt="" width="46" height="46" style="border-radius:14px;object-fit:cover">`
    : `<span class="emoji-artigo">${artigo.emoji || '💗'}</span>`;

  return `
    <tr>
      <td>
        <div class="d-flex align-items-center gap-3">
          ${capa}
          <div>
            <div class="rotulo-categoria">${escapar(artigo.categoria || '')}</div>
            <div class="fonte-titulo">${escapar(artigo.titulo)}</div>
            <div class="ajuda">${escapar(artigo.resumo || '')}</div>
          </div>
        </div>
      </td>
      <td><span class="chip">${artigo.categoria_emoji || '💗'} ${escapar(artigo.categoria || '')}</span></td>
      <td>
        <div class="selos">
          <span class="selo ${artigo.publicado ? 'selo-publicado' : 'selo-rascunho'}">${artigo.publicado ? 'Publicado' : 'Rascunho'}</span>
          ${artigo.destaque ? '<span class="selo selo-destaque">Destaque</span>' : ''}
        </div>
      </td>
      <td class="ajuda">${formatarData(artigo.atualizado_em)}</td>
      <td class="text-end">
        <div class="d-inline-flex gap-2">
          <a class="btn btn-contorno btn-sm" href="artigo.html?id=${artigo.id}">Editar</a>
          <button class="btn btn-contorno btn-sm" type="button"
                  data-publicar="${artigo.id}" data-estado="${artigo.publicado ? '0' : '1'}">
            ${artigo.publicado ? 'Despublicar' : 'Publicar'}
          </button>
          <button class="btn btn-perigo btn-sm" type="button"
                  data-excluir="${artigo.id}" data-titulo="${escapar(artigo.titulo)}">Excluir</button>
        </div>
      </td>
    </tr>`;
}

async function alternarPublicacao(id, publicar) {
  try {
    const artigo = await Api.alternarPublicacao(id, publicar);
    avisar(`“${escapar(artigo.titulo)}” ${publicar ? 'publicado — já aparece no aplicativo' : 'voltou para rascunho e saiu do aplicativo'}.`);
    carregarArtigos();
  } catch (erro) {
    tratarErro(erro);
  }
}

function pedirExclusao(id, titulo) {
  artigoParaExcluir = { id, titulo };
  document.getElementById('tituloExcluir').textContent = titulo;
  modalExcluir.show();
}

async function confirmarExclusao() {
  if (!artigoParaExcluir) return;
  try {
    await Api.excluirArtigo(artigoParaExcluir.id);
    modalExcluir.hide();
    avisar(`“${escapar(artigoParaExcluir.titulo)}” excluído. O aplicativo remove o conteúdo na próxima sincronização.`);
    artigoParaExcluir = null;
    carregarArtigos();
  } catch (erro) {
    modalExcluir.hide();
    tratarErro(erro);
  }
}
