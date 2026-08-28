package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.dao.ArtigoDao;
import br.unifebe.minhasaudefeminina.dao.ArtigoExcluidoDao;
import br.unifebe.minhasaudefeminina.dao.CategoriaDao;
import br.unifebe.minhasaudefeminina.dto.ArtigoListaResponse;
import br.unifebe.minhasaudefeminina.dto.ArtigoRequest;
import br.unifebe.minhasaudefeminina.dto.ArtigoResponse;
import br.unifebe.minhasaudefeminina.exception.RecursoNaoEncontradoException;
import br.unifebe.minhasaudefeminina.model.Artigo;
import br.unifebe.minhasaudefeminina.model.ArtigoExcluido;
import br.unifebe.minhasaudefeminina.model.Categoria;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
public class ArtigoService {

    private static final String EMOJI_PADRAO = "💗";
    private static final String AUTORA_PADRAO = "Equipe editorial";
    private static final int TEMPO_LEITURA_PADRAO = 3;
    private static final int TEMPO_LEITURA_MINIMO = 1;
    private static final int TEMPO_LEITURA_MAXIMO = 120;
    private static final int RESUMO_MAXIMO = 300;
    private static final int SLUG_MAXIMO = 170;

    private final ArtigoDao artigoDao;
    private final ArtigoExcluidoDao artigoExcluidoDao;
    private final CategoriaDao categoriaDao;

    public ArtigoService(ArtigoDao artigoDao, ArtigoExcluidoDao artigoExcluidoDao, CategoriaDao categoriaDao) {
        this.artigoDao = artigoDao;
        this.artigoExcluidoDao = artigoExcluidoDao;
        this.categoriaDao = categoriaDao;
    }

    @Cacheable("artigos")
    @Transactional(readOnly = true)
    public ArtigoListaResponse listar(String busca, Long categoriaId, String categoriaNome,
                                       String situacao, Boolean publicado) {
        List<Artigo> lista = artigoDao.findAll(especificacao(categoriaId, categoriaNome, situacao, publicado));

        if (busca != null && !busca.isBlank()) {
            String alvo = busca.toLowerCase();
            lista = lista.stream().filter(a -> contemTexto(a, alvo)).toList();
        }

        List<ArtigoResponse> ordenada = lista.stream()
                .sorted(Comparator.comparing(Artigo::isDestaque).reversed()
                        .thenComparing(Artigo::getAtualizadoEm, Comparator.reverseOrder()))
                .map(ArtigoResponse::resumo)
                .toList();

        return ArtigoListaResponse.de(ordenada);
    }

    @Cacheable(value = "artigo", key = "#id")
    @Transactional(readOnly = true)
    public ArtigoResponse buscar(Long id) {
        return ArtigoResponse.completo(buscarEntidade(id));
    }

    @CacheEvict(value = { "artigos", "artigo" }, allEntries = true)
    @Transactional
    public ArtigoResponse criar(ArtigoRequest dados) {
        Categoria categoria = buscarCategoria(dados.categoriaId());
        Artigo artigo = new Artigo();
        aplicar(artigo, dados, categoria);
        artigo.setSlug(gerarSlugUnico(dados.titulo()));
        return ArtigoResponse.completo(artigoDao.save(artigo));
    }

    @CacheEvict(value = { "artigos", "artigo" }, allEntries = true)
    @Transactional
    public ArtigoResponse atualizar(Long id, ArtigoRequest dados) {
        Artigo artigo = buscarEntidade(id);
        Categoria categoria = buscarCategoria(dados.categoriaId());
        aplicar(artigo, dados, categoria);
        if (artigo.getSlug() == null || artigo.getSlug().isBlank()) {
            artigo.setSlug(gerarSlugUnico(dados.titulo()));
        }
        return ArtigoResponse.completo(artigoDao.save(artigo));
    }

    @CacheEvict(value = { "artigos", "artigo" }, allEntries = true)
    @Transactional
    public ArtigoResponse alternarPublicacao(Long id, boolean publicado) {
        Artigo artigo = buscarEntidade(id);
        artigo.setPublicado(publicado);
        return ArtigoResponse.completo(artigoDao.save(artigo));
    }

    @CacheEvict(value = { "artigos", "artigo" }, allEntries = true)
    @Transactional
    public void excluir(Long id) {
        Artigo artigo = buscarEntidade(id);
        artigoExcluidoDao.save(new ArtigoExcluido(artigo.getId(), artigo.getTitulo()));
        artigoDao.delete(artigo);
    }

    private void aplicar(Artigo artigo, ArtigoRequest dados, Categoria categoria) {
        artigo.setTitulo(dados.titulo().trim());
        artigo.setConteudoHtml(dados.conteudoHtml());
        artigo.setResumo(resumoOuGerado(dados.resumo(), dados.conteudoHtml()));
        artigo.setEmoji(valorOu(dados.emoji(), EMOJI_PADRAO));
        artigo.setAutora(valorOu(dados.autora(), AUTORA_PADRAO));
        artigo.setTempoLeitura(tempoLeituraValido(dados.tempoLeitura()));
        artigo.setPublicado(dados.publicado() == null || dados.publicado());
        artigo.setDestaque(Boolean.TRUE.equals(dados.destaque()));
        artigo.setCapaUrl(dados.capaUrl());
        artigo.setCategoria(categoria);
    }

    private Categoria buscarCategoria(Long categoriaId) {
        return categoriaDao.findById(categoriaId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Categoria não encontrada."));
    }

    private Artigo buscarEntidade(Long id) {
        return artigoDao.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Artigo não encontrado."));
    }

    private static Specification<Artigo> especificacao(Long categoriaId, String categoriaNome,
                                                         String situacao, Boolean publicado) {
        return (root, query, cb) -> {
            if (Long.class != query.getResultType() && long.class != query.getResultType()) {
                root.fetch("categoria", JoinType.LEFT);
            }

            List<Predicate> predicados = new ArrayList<>();
            if (categoriaId != null) {
                predicados.add(cb.equal(root.get("categoria").get("id"), categoriaId));
            }
            if (categoriaNome != null && !categoriaNome.isBlank() && !"Todos".equalsIgnoreCase(categoriaNome)) {
                predicados.add(cb.equal(cb.lower(root.get("categoria").get("nome")), categoriaNome.toLowerCase()));
            }
            if ("publicado".equalsIgnoreCase(situacao)) {
                predicados.add(cb.isTrue(root.get("publicado")));
            } else if ("rascunho".equalsIgnoreCase(situacao)) {
                predicados.add(cb.isFalse(root.get("publicado")));
            }
            if (Boolean.TRUE.equals(publicado)) {
                predicados.add(cb.isTrue(root.get("publicado")));
            }
            return cb.and(predicados.toArray(new Predicate[0]));
        };
    }

    private static boolean contemTexto(Artigo artigo, String alvo) {
        return contem(artigo.getTitulo(), alvo)
                || contem(artigo.getResumo(), alvo)
                || contem(textoPuro(artigo.getConteudoHtml()), alvo);
    }

    private static boolean contem(String texto, String alvo) {
        return texto != null && texto.toLowerCase().contains(alvo);
    }

    private static String textoPuro(String html) {
        return html == null ? "" : html.replaceAll("<[^>]*>", " ");
    }

    private static String resumoOuGerado(String resumo, String conteudoHtml) {
        if (resumo != null && !resumo.isBlank()) {
            return resumo.trim();
        }
        String texto = textoPuro(conteudoHtml).replaceAll("\\s+", " ").trim();
        if (texto.isEmpty()) {
            return " ";
        }
        return texto.length() > RESUMO_MAXIMO ? texto.substring(0, RESUMO_MAXIMO) : texto;
    }

    private static String valorOu(String valor, String padrao) {
        return (valor == null || valor.isBlank()) ? padrao : valor.trim();
    }

    private static int tempoLeituraValido(Integer valor) {
        int tempo = valor == null ? TEMPO_LEITURA_PADRAO : valor;
        return Math.max(TEMPO_LEITURA_MINIMO, Math.min(TEMPO_LEITURA_MAXIMO, tempo));
    }

    private String gerarSlugUnico(String titulo) {
        String base = slugificar(titulo);
        String candidato = base;
        int sufixo = 2;
        while (artigoDao.existsBySlug(candidato)) {
            String marcador = "-" + sufixo++;
            int limite = Math.min(base.length(), SLUG_MAXIMO - marcador.length());
            candidato = base.substring(0, limite) + marcador;
        }
        return candidato;
    }

    private static String slugificar(String titulo) {
        String semAcentos = Normalizer.normalize(titulo, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        String slug = semAcentos.toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "");
        if (slug.isEmpty()) {
            slug = "artigo";
        }
        return slug.length() > SLUG_MAXIMO ? slug.substring(0, SLUG_MAXIMO) : slug;
    }
}
