/* =============================================================================
   artigo.js — criação e edição do artigo (edição hipermídia)
   ========================================================================== */

let editor = null;
let capaUrl = null;
const artigoId = parametroUrl('id');

document.addEventListener('DOMContentLoaded', iniciar);

async function iniciar() {
  if (!Auth.exigirSessao()) return;
  montarCabecalho('artigos');
  montarEditor();
  ligarEventos();

  try {
    await carregarCategorias();
    if (artigoId) await carregarArtigo(artigoId);
  } catch (erro) {
    tratarErro(erro);
  }
  atualizarPreview();
}

/* --------------------------------------------------------------- editor --- */

function montarEditor() {
  editor = new Quill('#editor', {
    theme: 'snow',
    placeholder: 'Escreva o conteúdo do artigo. Você pode misturar texto, imagens e vídeos.',
    modules: {
      toolbar: {
        container: [
          [{ header: [1, 2, 3, false] }],
          ['bold', 'italic', 'underline', 'strike'],
          [{ color: [] }, { background: [] }],
          [{ list: 'ordered' }, { list: 'bullet' }],
          [{ align: [] }],
          ['blockquote', 'link', 'image', 'video'],
          ['clean'],
        ],
      },
    },
  });

  const barra = editor.getModule('toolbar');

  barra.addHandler('image', () => {
    const entrada = document.getElementById('entradaMidia');
    entrada.accept = 'image/*';
    entrada.dataset.tipo = 'image';
    entrada.click();
  });

  barra.addHandler('video', () => {
    const link = prompt('Cole o link do vídeo (YouTube ou Vimeo).\nDeixe em branco para enviar um arquivo do computador.');
    if (link === null) return;
    if (link.trim() === '') {
      const entrada = document.getElementById('entradaMidia');
      entrada.accept = 'video/mp4,video/webm';
      entrada.dataset.tipo = 'video';
      entrada.click();
      return;
    }
    inserirNoEditor(converterLinkVideo(link.trim()), 'video');
  });

  editor.on('text-change', atualizarPreview);
}

function converterLinkVideo(link) {
  const youtube = link.match(/(?:youtu\.be\/|v=)([\w-]{11})/);
  if (youtube) return `https://www.youtube.com/embed/${youtube[1]}`;
  const vimeo = link.match(/vimeo\.com\/(\d+)/);
  if (vimeo) return `https://player.vimeo.com/video/${vimeo[1]}`;
  return link;
}

function inserirNoEditor(url, tipo) {
  const posicao = editor.getSelection(true)?.index ?? editor.getLength();
  editor.insertEmbed(posicao, tipo === 'video' ? 'video' : 'image', url, 'user');
  editor.setSelection(posicao + 1, Quill.sources.SILENT);
  atualizarPreview();
}

/* ------------------------------------------------------------- eventos --- */

function ligarEventos() {
  document.getElementById('entradaMidia').addEventListener('change', async (evento) => {
    const arquivo = evento.target.files[0];
    if (!arquivo) return;
    const status = document.getElementById('statusMidia');
    status.textContent = `Enviando ${arquivo.name}…`;
    try {
      const { url } = await Api.enviarMidia(arquivo);
      inserirNoEditor(url, arquivo.type.startsWith('video') ? 'video' : 'image');
      status.textContent = `${arquivo.name} inserido no conteúdo.`;
    } catch (erro) {
      status.textContent = '';
      tratarErro(erro);
    } finally {
      evento.target.value = '';
    }
  });

  document.getElementById('capa').addEventListener('change', async (evento) => {
    const arquivo = evento.target.files[0];
    if (!arquivo) return;
    try {
      const { url } = await Api.enviarMidia(arquivo);
      definirCapa(url);
    } catch (erro) {
      tratarErro(erro);
    } finally {
      evento.target.value = '';
    }
  });

  document.getElementById('removerCapa').onclick = () => definirCapa(null);

  ['titulo', 'resumo', 'emoji'].forEach((id) => {
    document.getElementById(id).addEventListener('input', atualizarPreview);
  });
  document.getElementById('categoria_id').addEventListener('change', atualizarPreview);

  document.getElementById('formArtigo').addEventListener('submit', salvar);
}

function definirCapa(url) {
  capaUrl = url;
  const area = document.getElementById('areaCapa');
  if (url) {
    document.getElementById('previaCapa').src = url;
    area.classList.remove('d-none');
  } else {
    area.classList.add('d-none');
  }
}

/* --------------------------------------------------------------- dados --- */

async function carregarCategorias() {
  const categorias = await Api.listarCategorias();
  const select = document.getElementById('categoria_id');
  select.innerHTML = categorias
    .map((c) => `<option value="${c.id}">${c.emoji} ${escapar(c.nome)}</option>`)
    .join('');
}

async function carregarArtigo(id) {
  const artigo = await Api.obterArtigo(id);
  document.getElementById('tituloTela').textContent = 'Editar artigo';
  document.title = `${artigo.titulo} · Minha Saúde Feminina`;
  document.getElementById('titulo').value = artigo.titulo ?? '';
  document.getElementById('resumo').value = artigo.resumo ?? '';
  document.getElementById('emoji').value = artigo.emoji ?? '💗';
  document.getElementById('autora').value = artigo.autora ?? '';
  document.getElementById('tempo_leitura').value = artigo.tempo_leitura ?? 3;
  document.getElementById('categoria_id').value = artigo.categoria_id;
  document.getElementById('publicado').checked = Boolean(artigo.publicado);
  document.getElementById('destaque').checked = Boolean(artigo.destaque);
  if (artigo.capa_url) definirCapa(artigo.capa_url);
  editor.clipboard.dangerouslyPasteHTML(artigo.conteudo_html || '');
}

function montarPayload() {
  const html = editor.root.innerHTML;
  const temMidia = Boolean(editor.root.querySelector('img, iframe, video'));
  return {
    titulo: document.getElementById('titulo').value.trim(),
    resumo: document.getElementById('resumo').value.trim(),
    conteudo_html: editor.getText().trim() === '' && !temMidia ? '' : html,
    emoji: document.getElementById('emoji').value.trim() || '💗',
    autora: document.getElementById('autora').value.trim() || 'Equipe editorial',
    categoria_id: Number(document.getElementById('categoria_id').value),
    tempo_leitura: Number(document.getElementById('tempo_leitura').value) || 3,
    publicado: document.getElementById('publicado').checked,
    destaque: document.getElementById('destaque').checked,
    capa_url: capaUrl,
  };
}

async function salvar(evento) {
  evento.preventDefault();
  const payload = montarPayload();

  if (!payload.titulo) {
    avisar('Informe o título do artigo.', 'erro');
    document.getElementById('titulo').focus();
    return;
  }
  if (!payload.conteudo_html) {
    avisar('Escreva o conteúdo do artigo antes de salvar.', 'erro');
    editor.focus();
    return;
  }

  const botao = document.getElementById('botaoSalvar');
  botao.disabled = true;
  botao.textContent = 'Salvando…';

  try {
    if (artigoId) {
      await Api.atualizarArtigo(artigoId, payload);
      avisarNaProxima(`“${escapar(payload.titulo)}” atualizado. O aplicativo recebe a nova versão na próxima sincronização.`);
    } else {
      await Api.criarArtigo(payload);
      avisarNaProxima(`“${escapar(payload.titulo)}” criado${payload.publicado ? ' e já disponível no aplicativo' : ' como rascunho'}.`);
    }
    location.href = 'index.html';
  } catch (erro) {
    tratarErro(erro);
    botao.disabled = false;
    botao.textContent = 'Salvar artigo';
  }
}

/* ------------------------------------------------------- pré-visualização */

function atualizarPreview() {
  const html = editor.root.innerHTML;
  const select = document.getElementById('categoria_id');
  const categoria = select.selectedOptions[0]?.text ?? '';

  document.getElementById('pvTitulo').textContent = document.getElementById('titulo').value || 'Título do artigo';
  document.getElementById('pvEmoji').textContent = document.getElementById('emoji').value || '💗';
  document.getElementById('pvCategoria').textContent = categoria.replace(/[^\p{L}\s]/gu, '').trim().toUpperCase();
  document.getElementById('pvResumo').textContent =
    document.getElementById('resumo').value || textoDeHtml(html).slice(0, 120) || 'O resumo aparece aqui.';
  document.getElementById('pvConteudo').innerHTML = html;
}
