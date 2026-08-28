package br.unifebe.minhasaudefeminina.dao;

import br.unifebe.minhasaudefeminina.model.ArtigoExcluido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ArtigoExcluidoDao extends JpaRepository<ArtigoExcluido, Long> {

    List<ArtigoExcluido> findAllByExcluidoEmAfter(LocalDateTime marco);
}
