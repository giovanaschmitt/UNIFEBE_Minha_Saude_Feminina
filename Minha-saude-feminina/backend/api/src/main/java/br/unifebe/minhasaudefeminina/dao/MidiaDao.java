package br.unifebe.minhasaudefeminina.dao;

import br.unifebe.minhasaudefeminina.model.Midia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MidiaDao extends JpaRepository<Midia, Long> {
}
