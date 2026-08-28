package br.unifebe.minhasaudefeminina.service;

import java.util.List;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import br.unifebe.minhasaudefeminina.dao.CategoriaDao;
import br.unifebe.minhasaudefeminina.dto.CategoriaRequest;
import br.unifebe.minhasaudefeminina.dto.CategoriaResponse;
import br.unifebe.minhasaudefeminina.exception.ConflitoException;
import br.unifebe.minhasaudefeminina.exception.RecursoNaoEncontradoException;
import br.unifebe.minhasaudefeminina.model.Categoria;

@Service
public class CategoriaService {

    private static final String EMOJI_PADRAO = "💗";
    private static final String COR_PADRAO = "#B81E4D";

    private final CategoriaDao categoriaDao;

    public CategoriaService(CategoriaDao categoriaDao) {
        this.categoriaDao = categoriaDao;
    }

    @Cacheable("categorias")
    @Transactional(readOnly = true)
    public List<CategoriaResponse> listar() {
        return categoriaDao.findAllByOrderByOrdemAscNomeAsc()
                .stream()
                .map(CategoriaResponse::de)
                .toList();
    }

    @Cacheable(value = "categoria", key = "#id")
    @Transactional(readOnly = true)
    public CategoriaResponse buscar(Long id) {
        return CategoriaResponse.de(buscarEntidade(id));
    }

    @CacheEvict(value = { "categorias", "categoria" }, allEntries = true)
    @Transactional
    public CategoriaResponse criar(CategoriaRequest dados) {
        String nome = dados.nome().trim();

        if (categoriaDao.existsByNomeIgnoreCase(nome)) {
            throw new ConflitoException("Já existe uma categoria com esse nome.");
        }

        Categoria categoria = new Categoria(
                nome,
                valorOu(dados.emoji(), EMOJI_PADRAO),
                valorOu(dados.cor(), COR_PADRAO),
                dados.ordem() == null ? 0 : dados.ordem());

        return CategoriaResponse.de(categoriaDao.save(categoria));
    }

    @CacheEvict(value = { "categorias", "categoria" }, allEntries = true)
    @Transactional
    public CategoriaResponse atualizar(Long id, CategoriaRequest dados) {
        Categoria categoria = buscarEntidade(id);
        String nome = dados.nome().trim();

        if (categoriaDao.existsByNomeIgnoreCaseAndIdNot(nome, id)) {
            throw new ConflitoException("Já existe uma categoria com esse nome.");
        }

        categoria.setNome(nome);
        categoria.setEmoji(valorOu(dados.emoji(), categoria.getEmoji()));
        categoria.setCor(valorOu(dados.cor(), categoria.getCor()));
        if (dados.ordem() != null) {
            categoria.setOrdem(dados.ordem());
        }

        return CategoriaResponse.de(categoriaDao.save(categoria));
    }

    @CacheEvict(value = { "categorias", "categoria" }, allEntries = true)
    @Transactional
    public void excluir(Long id) {
        Categoria categoria = buscarEntidade(id);

        long artigos = categoriaDao.contarArtigos(id);
        if (artigos > 0) {
            throw new ConflitoException(
                    "Mova os artigos para outra categoria antes de excluir esta.");
        }

        categoriaDao.delete(categoria);
    }

    private Categoria buscarEntidade(Long id) {
        return categoriaDao.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Categoria não encontrada."));
    }

    private static String valorOu(String valor, String padrao) {
        return (valor == null || valor.isBlank()) ? padrao : valor.trim();
    }
}
