package br.unifebe.minhasaudefeminina.dao;

import br.unifebe.minhasaudefeminina.model.RegistroSintoma;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface RegistroSintomaDao extends JpaRepository<RegistroSintoma, Long> {

    @EntityGraph(attributePaths = "sintoma")
    List<RegistroSintoma> findAllByUidUsuariaOrderByDataRegistroDescCriadoEmDesc(String uidUsuaria);

    Optional<RegistroSintoma> findByIdAndUidUsuaria(Long id, String uidUsuaria);

    Optional<RegistroSintoma> findByUidUsuariaAndSintomaIdAndDataRegistro(
            String uidUsuaria, Long sintomaId, LocalDate dataRegistro);
}
