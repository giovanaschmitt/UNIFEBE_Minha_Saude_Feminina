/* =============================================================================
   api.js — camada de acesso ao back-end
   ========================================================================== */

const API_CONFIG = {
  base: window.API_BASE_URL || 'http://localhost:8080/api',
  demo: false,
};

(function carregarConfiguracao() {
  const salvo = sessionStorage.getItem('api_base');
  if (salvo) API_CONFIG.base = salvo;
  const modo = sessionStorage.getItem('api_demo');
  if (modo !== null) API_CONFIG.demo = modo === '1';
})();

function definirBaseApi(url) {
  API_CONFIG.base = url.replace(/\/$/, '');
  sessionStorage.setItem('api_base', API_CONFIG.base);
}

function definirModoDemo(ativo) {
  API_CONFIG.demo = ativo;
  sessionStorage.setItem('api_demo', ativo ? '1' : '0');
}

/* ------------------------------------------------------------ requisição --- */

class ErroApi extends Error {
  constructor(mensagem, status) {
    super(mensagem);
    this.status = status;
  }
}

async function requisitar(caminho, opcoes = {}) {
  const url = `${API_CONFIG.base}${caminho}`;

  const cabecalhos = opcoes.corpoBruto ? {} : { 'Content-Type': 'application/json' };
  const token = typeof Auth !== 'undefined' ? Auth.token() : null;
  if (token) cabecalhos.Authorization = `Bearer ${token}`;

  let resposta;
  try {
    resposta = await fetch(url, { ...opcoes, headers: cabecalhos });
  } catch (erro) {
    throw new ErroApi(`Sem resposta de ${url}. Verifique se a API está no ar e se o CORS libera esta origem.`, 0);
  }

  if (resposta.status === 204) return null;

  const texto = await resposta.text();
  let dados = null;
  if (texto) {
    try {
      dados = JSON.parse(texto);
    } catch {
      dados = { erro: texto };
    }
  }

  if (!resposta.ok) {
    throw new ErroApi(dados?.erro || `A API respondeu ${resposta.status}.`, resposta.status);
  }
  return dados;
}

const Api = {
  /* -------------------------------------------------------- categorias --- */

  listarCategorias() {
    if (API_CONFIG.demo) return Demo.listarCategorias();
    return requisitar('/categorias');
  },

  criarCategoria(categoria) {
    if (API_CONFIG.demo) return Demo.criarCategoria(categoria);
    return requisitar('/categorias', { method: 'POST', body: JSON.stringify(categoria) });
  },

  excluirCategoria(id) {
    if (API_CONFIG.demo) return Demo.excluirCategoria(id);
    return requisitar(`/categorias/${id}`, { method: 'DELETE' });
  },

  /* ------------------------------------------------------------ artigos --- */

  listarArtigos(filtros = {}) {
    if (API_CONFIG.demo) return Demo.listarArtigos(filtros);
    const parametros = new URLSearchParams();
    Object.entries(filtros).forEach(([chave, valor]) => {
      if (valor !== '' && valor !== null && valor !== undefined) parametros.set(chave, valor);
    });
    const consulta = parametros.toString();
    return requisitar(`/artigos${consulta ? `?${consulta}` : ''}`);
  },

  obterArtigo(id) {
    if (API_CONFIG.demo) return Demo.obterArtigo(id);
    return requisitar(`/artigos/${id}`);
  },

  criarArtigo(artigo) {
    if (API_CONFIG.demo) return Demo.criarArtigo(artigo);
    return requisitar('/artigos', { method: 'POST', body: JSON.stringify(artigo) });
  },

  atualizarArtigo(id, artigo) {
    if (API_CONFIG.demo) return Demo.atualizarArtigo(id, artigo);
    return requisitar(`/artigos/${id}`, { method: 'PUT', body: JSON.stringify(artigo) });
  },

  alternarPublicacao(id, publicado) {
    if (API_CONFIG.demo) return Demo.alternarPublicacao(id, publicado);
    return requisitar(`/artigos/${id}/publicacao`, {
      method: 'PATCH',
      body: JSON.stringify({ publicado }),
    });
  },

  excluirArtigo(id) {
    if (API_CONFIG.demo) return Demo.excluirArtigo(id);
    return requisitar(`/artigos/${id}`, { method: 'DELETE' });
  },

  /* -------------------------------------------------------------- mídia --- */

  async enviarMidia(arquivo) {
    if (API_CONFIG.demo) return Demo.enviarMidia(arquivo);
    const dados = new FormData();
    dados.append('arquivo', arquivo);
    return requisitar('/midia', { method: 'POST', body: dados, corpoBruto: true });
  },

  /* ------------------------------------------------------ sincronização --- */

  sincronizar(desde) {
    if (API_CONFIG.demo) return Demo.sincronizar(desde);
    return requisitar(`/sincronizacao${desde ? `?desde=${encodeURIComponent(desde)}` : ''}`);
  },
};

/* ------------------------------------------------------------------ Demo --- */

const Demo = (() => {
  const agora = () => new Date().toISOString().slice(0, 19);

  const categorias = [
    { id: 1, nome: 'Menstruação', emoji: '🩸', cor: '#C2185B', ordem: 1 },
    { id: 2, nome: 'Contracepção', emoji: '💊', cor: '#D81B60', ordem: 2 },
    { id: 3, nome: 'Gravidez', emoji: '🤰', cor: '#AD1457', ordem: 3 },
    { id: 4, nome: 'Autocuidado', emoji: '🌸', cor: '#E91E8C', ordem: 4 },
  ];

  const artigos = [
    {
      id: 1,
      titulo: 'Cólicas menstruais: quando se preocupar',
      resumo: 'Saiba diferenciar cólicas normais de sinais médicos.',
      emoji: '🩸',
      categoria_id: 1,
      autora: 'Dra. Helena Prado',
      tempo_leitura: 4,
      publicado: true,
      destaque: true,
      capa_url: null,
      criado_em: agora(),
      atualizado_em: agora(),
      conteudo_html:
        '<h2>O que é uma cólica comum</h2><p>A cólica menstrual acontece porque o útero se contrai para eliminar o endométrio. Na maioria das vezes ela dura <strong>de um a três dias</strong> e melhora com calor local e analgésicos simples.</p><h2>Sinais que pedem uma consulta</h2><ul><li>Dor que impede as atividades do dia</li><li>Sangramento muito intenso</li><li>Dor fora do período menstrual</li></ul><blockquote>Dor que não passa com analgésico comum merece avaliação ginecológica.</blockquote>',
    },
    {
      id: 2,
      titulo: 'Fase folicular e libido',
      resumo: 'Entenda como seus hormônios afetam seu desejo.',
      emoji: '⚡',
      categoria_id: 1,
      autora: 'Equipe editorial',
      tempo_leitura: 3,
      publicado: true,
      destaque: false,
      capa_url: null,
      criado_em: agora(),
      atualizado_em: agora(),
      conteudo_html:
        '<p>Na primeira metade do ciclo o estrogênio sobe e traz mais disposição e desejo. É um bom momento para <em>treinos mais intensos</em> e para tarefas que exigem concentração.</p>',
    },
    {
      id: 3,
      titulo: 'Tipos de anticoncepcional',
      resumo: 'Conheça as opções e como cada uma age no seu corpo.',
      emoji: '💊',
      categoria_id: 2,
      autora: 'Dra. Helena Prado',
      tempo_leitura: 6,
      publicado: true,
      destaque: false,
      capa_url: null,
      criado_em: agora(),
      atualizado_em: agora(),
      conteudo_html:
        '<h2>Hormonais</h2><p>Pílula combinada, minipílula, adesivo, injeção, implante e DIU hormonal.</p><h2>Não hormonais</h2><p>DIU de cobre, preservativo e métodos de barreira.</p><p>A escolha depende de histórico de saúde, rotina e preferência. <strong>Converse com sua ginecologista.</strong></p>',
    },
    {
      id: 4,
      titulo: 'Primeiros sinais de gravidez',
      resumo: 'O que o seu corpo sente nas primeiras semanas.',
      emoji: '🤰',
      categoria_id: 3,
      autora: 'Equipe editorial',
      tempo_leitura: 4,
      publicado: false,
      destaque: false,
      capa_url: null,
      criado_em: agora(),
      atualizado_em: agora(),
      conteudo_html:
        '<p>Atraso menstrual, sensibilidade nas mamas, sono e enjoos matinais estão entre os primeiros sinais. O teste de farmácia costuma ser confiável a partir do primeiro dia de atraso.</p>',
    },
  ];

  const excluidos = [];
  let proximoArtigo = 5;
  let proximaCategoria = 5;

  const pausa = (dado) => new Promise((resolver) => setTimeout(() => resolver(dado), 120));
  const clonar = (dado) => JSON.parse(JSON.stringify(dado));

  function enriquecer(artigo, completo = true) {
    const categoria = categorias.find((c) => c.id === artigo.categoria_id);
    const dado = {
      ...clonar(artigo),
      categoria: categoria?.nome ?? 'Sem categoria',
      categoria_cor: categoria?.cor ?? '#B81E4D',
      categoria_emoji: categoria?.emoji ?? '💗',
    };
    if (!completo) delete dado.conteudo_html;
    return dado;
  }

  function textoPuro(html) {
    const caixa = document.createElement('div');
    caixa.innerHTML = html || '';
    return caixa.textContent.replace(/\s+/g, ' ').trim();
  }

  return {
    listarCategorias: () => pausa(clonar(categorias).sort((a, b) => a.ordem - b.ordem)),

    criarCategoria(categoria) {
      const nova = { id: proximaCategoria++, ordem: 0, emoji: '💗', cor: '#B81E4D', ...categoria };
      categorias.push(nova);
      return pausa(clonar(nova));
    },

    excluirCategoria(id) {
      if (artigos.some((a) => a.categoria_id === Number(id))) {
        return Promise.reject(new ErroApi('Mova os artigos para outra categoria antes de excluir esta.', 409));
      }
      const posicao = categorias.findIndex((c) => c.id === Number(id));
      if (posicao >= 0) categorias.splice(posicao, 1);
      return pausa(null);
    },

    listarArtigos(filtros = {}) {
      let lista = artigos.slice();
      if (filtros.publicado === true || filtros.publicado === 'true') {
        lista = lista.filter((a) => a.publicado);
      }
      if (filtros.situacao === 'publicado') lista = lista.filter((a) => a.publicado);
      if (filtros.situacao === 'rascunho') lista = lista.filter((a) => !a.publicado);
      if (filtros.categoria_id) lista = lista.filter((a) => a.categoria_id === Number(filtros.categoria_id));
      if (filtros.categoria && filtros.categoria !== 'Todos') {
        const categoria = categorias.find((c) => c.nome === filtros.categoria);
        lista = lista.filter((a) => a.categoria_id === categoria?.id);
      }
      if (filtros.busca) {
        const alvo = filtros.busca.toLowerCase();
        lista = lista.filter((a) =>
          `${a.titulo} ${a.resumo} ${textoPuro(a.conteudo_html)}`.toLowerCase().includes(alvo));
      }
      lista.sort((a, b) => Number(b.destaque) - Number(a.destaque)
        || b.atualizado_em.localeCompare(a.atualizado_em));
      return pausa({ total: lista.length, artigos: lista.map((a) => enriquecer(a, false)) });
    },

    obterArtigo(id) {
      const artigo = artigos.find((a) => a.id === Number(id));
      if (!artigo) return Promise.reject(new ErroApi('Artigo não encontrado.', 404));
      return pausa(enriquecer(artigo));
    },

    criarArtigo(dados) {
      const artigo = {
        id: proximoArtigo++,
        publicado: true,
        destaque: false,
        capa_url: null,
        emoji: '💗',
        autora: 'Equipe editorial',
        tempo_leitura: 3,
        ...dados,
        categoria_id: Number(dados.categoria_id),
        resumo: dados.resumo || textoPuro(dados.conteudo_html).slice(0, 160),
        criado_em: agora(),
        atualizado_em: agora(),
      };
      artigos.push(artigo);
      return pausa(enriquecer(artigo));
    },

    atualizarArtigo(id, dados) {
      const artigo = artigos.find((a) => a.id === Number(id));
      if (!artigo) return Promise.reject(new ErroApi('Artigo não encontrado.', 404));
      Object.assign(artigo, dados, {
        categoria_id: Number(dados.categoria_id ?? artigo.categoria_id),
        resumo: dados.resumo || textoPuro(dados.conteudo_html ?? artigo.conteudo_html).slice(0, 160),
        atualizado_em: agora(),
      });
      return pausa(enriquecer(artigo));
    },

    alternarPublicacao(id, publicado) {
      const artigo = artigos.find((a) => a.id === Number(id));
      if (!artigo) return Promise.reject(new ErroApi('Artigo não encontrado.', 404));
      artigo.publicado = publicado;
      artigo.atualizado_em = agora();
      return pausa(enriquecer(artigo));
    },

    excluirArtigo(id) {
      const posicao = artigos.findIndex((a) => a.id === Number(id));
      if (posicao < 0) return Promise.reject(new ErroApi('Artigo não encontrado.', 404));
      const [artigo] = artigos.splice(posicao, 1);
      excluidos.push({ artigo_id: artigo.id, titulo: artigo.titulo, excluido_em: agora() });
      return pausa(null);
    },

    enviarMidia(arquivo) {
      return pausa({ url: URL.createObjectURL(arquivo) });
    },

    sincronizar(desde) {
      const marco = desde || '0000';
      const atualizados = artigos
        .filter((a) => a.publicado && a.atualizado_em > marco)
        .map((a) => enriquecer(a));
      const removidos = [
        ...excluidos.filter((e) => e.excluido_em > marco).map((e) => e.artigo_id),
        ...artigos.filter((a) => !a.publicado).map((a) => a.id),
      ];
      return pausa({ servidor_em: agora(), atualizados, removidos });
    },
  };
})();
