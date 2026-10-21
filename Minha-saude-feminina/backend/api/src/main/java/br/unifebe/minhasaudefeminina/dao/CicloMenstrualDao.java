package br.unifebe.minhasaudefeminina.dao;

import br.unifebe.minhasaudefeminina.model.CicloMenstrual;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface CicloMenstrualDao extends JpaRepository<CicloMenstrual, Long> {

    List<CicloMenstrual> findAllByUidUsuariaOrderByDataInicioDesc(String uidUsuaria);

    Optional<CicloMenstrual> findByIdAndUidUsuaria(Long id, String uidUsuaria);

    boolean existsByUidUsuariaAndDataInicioAndIdNot(String uidUsuaria, LocalDate dataInicio, Long id);

    boolean existsByUidUsuariaAndDataInicio(String uidUsuaria, LocalDate dataInicio);
}
