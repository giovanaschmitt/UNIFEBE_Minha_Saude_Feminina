package br.unifebe.minhasaudefeminina.dao;

import br.unifebe.minhasaudefeminina.model.Artigo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ArtigoDao extends JpaRepository<Artigo, Long>, JpaSpecificationExecutor<Artigo> {

    List<Artigo> findAllByPublicadoTrueAndAtualizadoEmAfter(LocalDateTime marco);

    List<Artigo> findAllByPublicadoTrue();

    List<Artigo> findAllByPublicadoFalse();

    boolean existsBySlug(String slug);
}
