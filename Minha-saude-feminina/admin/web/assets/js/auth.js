/* =============================================================================
   auth.js — sessão da pessoa que gerencia os conteúdos
   ========================================================================== */

const AUTH_CONFIG = {
  modo: 'firebase',

  firebase: {
    apiKey: 'AIzaSyAtRom_V6WBVmW90dOiUJJNgdr3IgRmVNc',
    authDomain: 'minhasaudefeminina-5f28c.firebaseapp.com',
    projectId: 'minhasaudefeminina-5f28c',
    appId: '',
  },
};

const CHAVE_SESSAO = 'sessao_gestao';

const Guardado = {
  ler(chave) {
    try {
      return localStorage.getItem(chave) ?? sessionStorage.getItem(chave);
    } catch {
      return null;
    }
  },
  gravar(chave, valor) {
    try {
      localStorage.setItem(chave, valor);
    } catch {
      try { sessionStorage.setItem(chave, valor); } catch {}
    }
  },
  apagar(chave) {
    try { localStorage.removeItem(chave); } catch {}
    try { sessionStorage.removeItem(chave); } catch {}
  },
};

const Auth = {
  sessao() {
    const bruto = Guardado.ler(CHAVE_SESSAO);
    return bruto ? JSON.parse(bruto) : null;
  },

  token() {
    return this.sessao()?.token ?? null;
  },

  autenticado() {
    return Boolean(this.token());
  },

  guardar(sessao) {
    Guardado.gravar(CHAVE_SESSAO, JSON.stringify(sessao));
  },

  sair() {
    Guardado.apagar(CHAVE_SESSAO);
    location.href = 'login.html';
  },

  exigirSessao() {
    if (AUTH_CONFIG.modo === 'demo' && !this.autenticado()) {
      return true;
    }
    if (!this.autenticado()) {
      location.href = `login.html?proximo=${encodeURIComponent(location.pathname.split('/').pop())}`;
      return false;
    }
    return true;
  },

  async entrar(email, senha) {
    if (AUTH_CONFIG.modo === 'firebase') return entrarComFirebase(email, senha);
    if (AUTH_CONFIG.modo === 'api') return entrarComApi(email, senha);
    return entrarNoModoDemo(email);
  },
};

/* ----------------------------------------------------------------- demo --- */

async function entrarNoModoDemo(email) {
  await new Promise((r) => setTimeout(r, 300));
  const sessao = {
    token: 'demo-token',
    email: email || 'demo@unifebe.edu.br',
    nome: (email || 'demo').split('@')[0],
  };
  Auth.guardar(sessao);
  return sessao;
}

/* ------------------------------------------------------------ API própria --- */

async function entrarComApi(email, senha) {
  const resposta = await fetch(`${API_CONFIG.base}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, senha }),
  });

  const dados = await resposta.json().catch(() => ({}));
  if (!resposta.ok) {
    throw new Error(dados.erro || (resposta.status === 401
      ? 'E-mail ou senha incorretos.'
      : `A API respondeu ${resposta.status}.`));
  }

  const sessao = { token: dados.token, email: dados.email || email, nome: dados.nome || email };
  Auth.guardar(sessao);
  return sessao;
}

/* --------------------------------------------------------------- Firebase --- */

let appFirebase = null;

async function entrarComFirebase(email, senha) {
  if (!AUTH_CONFIG.firebase.apiKey) {
    throw new Error('Configure AUTH_CONFIG.firebase em assets/js/auth.js antes de usar o modo Firebase.');
  }

  const { initializeApp } = await import('https://www.gstatic.com/firebasejs/10.13.2/firebase-app.js');
  const { getAuth, signInWithEmailAndPassword } =
    await import('https://www.gstatic.com/firebasejs/10.13.2/firebase-auth.js');

  appFirebase = appFirebase || initializeApp(AUTH_CONFIG.firebase);
  const auth = getAuth(appFirebase);

  let credencial;
  try {
    credencial = await signInWithEmailAndPassword(auth, email, senha);
  } catch (erro) {
    throw new Error(traduzirErroFirebase(erro.code));
  }

  const token = await credencial.user.getIdToken();
  const sessao = {
    token,
    email: credencial.user.email,
    nome: credencial.user.displayName || credencial.user.email.split('@')[0],
    uid: credencial.user.uid,
  };
  Auth.guardar(sessao);

  await confirmarTokenNoBack(sessao);

  return sessao;
}

/* ------------------------------------------------- verificação no back --- */

async function confirmarTokenNoBack(sessao) {
  let resposta;
  try {
    resposta = await fetch(`${API_CONFIG.base}/usuarios/me`, {
      headers: { Authorization: `Bearer ${sessao.token}` },
    });
  } catch {
    throw new Error(`Login no Firebase funcionou, mas não houve resposta de ${API_CONFIG.base}. Verifique se a API está no ar e se o CORS libera esta origem.`);
  }

  if (!resposta.ok) {
    const corpo = await resposta.json().catch(() => ({}));
    throw new Error(corpo.erro || corpo.message
      || `Login no Firebase funcionou, mas a API recusou o token (status ${resposta.status}). Confira se o projeto do firebase-service-account.json no back é o mesmo deste app Web.`);
  }
}

function traduzirErroFirebase(codigo) {
  const mensagens = {
    'auth/invalid-email': 'E-mail em formato inválido.',
    'auth/user-disabled': 'Esta conta está desativada.',
    'auth/user-not-found': 'E-mail ou senha incorretos.',
    'auth/wrong-password': 'E-mail ou senha incorretos.',
    'auth/invalid-credential': 'E-mail ou senha incorretos.',
    'auth/too-many-requests': 'Muitas tentativas seguidas. Aguarde alguns minutos.',
    'auth/network-request-failed': 'Sem conexão com o servidor de autenticação.',
    'auth/operation-not-allowed': 'Login por e-mail/senha não está ativado neste projeto do Firebase (Console → Authentication → Sign-in method).',
    'auth/api-key-not-valid.-please-pass-a-valid-api-key.': 'A apiKey configurada em auth.js não é válida para este projeto.',
  };
  return mensagens[codigo] || 'Não foi possível entrar. Tente novamente.';
}
