package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.dao.ArtigoDao;
import br.unifebe.minhasaudefeminina.dao.ArtigoExcluidoDao;
import br.unifebe.minhasaudefeminina.dto.ArtigoResponse;
import br.unifebe.minhasaudefeminina.dto.SincronizacaoResponse;
import br.unifebe.minhasaudefeminina.model.Artigo;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
public class SincronizacaoService {

    private final ArtigoDao artigoDao;
    private final ArtigoExcluidoDao artigoExcluidoDao;

    public SincronizacaoService(ArtigoDao artigoDao, ArtigoExcluidoDao artigoExcluidoDao) {
        this.artigoDao = artigoDao;
        this.artigoExcluidoDao = artigoExcluidoDao;
    }

    @Transactional(readOnly = true)
    public SincronizacaoResponse sincronizar(LocalDateTime desde) {
        List<Artigo> atualizados = desde == null
                ? artigoDao.findAllByPublicadoTrue()
                : artigoDao.findAllByPublicadoTrueAndAtualizadoEmAfter(desde);

        Set<Long> removidos = new LinkedHashSet<>();
        if (desde != null) {
            artigoExcluidoDao.findAllByExcluidoEmAfter(desde)
                    .forEach(excluido -> removidos.add(excluido.getArtigoId()));
        }
        artigoDao.findAllByPublicadoFalse()
                .forEach(artigo -> removidos.add(artigo.getId()));

        return new SincronizacaoResponse(
                LocalDateTime.now(),
                atualizados.stream().map(ArtigoResponse::completo).toList(),
                List.copyOf(removidos));
    }
}
