package br.unifebe.minhasaudefeminina.dao;

import br.unifebe.minhasaudefeminina.model.Sintoma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SintomaDao extends JpaRepository<Sintoma, Long> {

    List<Sintoma> findAllByAtivoTrueOrderByOrdem();

    Optional<Sintoma> findByNomeIgnoreCaseAndAtivoTrue(String nome);
}
