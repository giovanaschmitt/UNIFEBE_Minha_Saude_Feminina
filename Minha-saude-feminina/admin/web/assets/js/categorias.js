/* =============================================================================
   categorias.js — cadastro das categorias usadas como filtros no aplicativo
   ========================================================================== */

document.addEventListener('DOMContentLoaded', async () => {
  if (!Auth.exigirSessao()) return;
  montarCabecalho('categorias');
  document.getElementById('formCategoria').addEventListener('submit', criar);
  await carregar();
});

async function carregar() {
  try {
    const [categorias, artigos] = await Promise.all([
      Api.listarCategorias(),
      Api.listarArtigos({}),
    ]);
    const contagem = artigos.artigos.reduce((mapa, artigo) => {
      mapa[artigo.categoria_id] = (mapa[artigo.categoria_id] || 0) + 1;
      return mapa;
    }, {});
    desenhar(categorias, contagem);
  } catch (erro) {
    tratarErro(erro);
  }
}

function desenhar(categorias, contagem) {
  document.getElementById('previaChips').innerHTML =
    ['<span class="chip ativo">✨ Todos</span>']
      .concat(categorias.map((c) => `<span class="chip">${c.emoji} ${escapar(c.nome)}</span>`))
      .join('');

  document.getElementById('corpoTabela').innerHTML = categorias.map((c) => `
    <tr>
      <td>
        <span class="me-2">${c.emoji}</span><strong>${escapar(c.nome)}</strong>
        <span class="d-inline-block ms-2 align-middle" style="width:14px;height:14px;border-radius:50%;background:${escapar(c.cor)}"></span>
        <div class="ajuda">${contagem[c.id] || 0} artigo(s)</div>
      </td>
      <td class="ajuda">${c.ordem}</td>
      <td class="text-end">
        <button class="btn btn-perigo btn-sm" type="button" data-excluir="${c.id}" data-nome="${escapar(c.nome)}">Excluir</button>
      </td>
    </tr>`).join('');

  document.querySelectorAll('[data-excluir]').forEach((botao) => {
    botao.onclick = () => excluir(Number(botao.dataset.excluir), botao.dataset.nome);
  });
}

async function criar(evento) {
  evento.preventDefault();
  const nome = document.getElementById('nome').value.trim();
  if (!nome) return;

  try {
    await Api.criarCategoria({
      nome,
      emoji: document.getElementById('emoji').value.trim() || '💗',
      cor: document.getElementById('cor').value,
      ordem: Number(document.getElementById('ordem').value) || 0,
    });
    document.getElementById('formCategoria').reset();
    avisar(`Categoria “${escapar(nome)}” criada.`);
    carregar();
  } catch (erro) {
    tratarErro(erro);
  }
}

async function excluir(id, nome) {
  if (!confirm(`Excluir a categoria “${nome}”?`)) return;
  try {
    await Api.excluirCategoria(id);
    avisar(`Categoria “${escapar(nome)}” excluída.`);
    carregar();
  } catch (erro) {
    tratarErro(erro);
  }
}
