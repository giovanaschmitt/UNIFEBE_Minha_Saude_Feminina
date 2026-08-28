package br.unifebe.minhasaudefeminina.dao;

import br.unifebe.minhasaudefeminina.model.Categoria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoriaDao extends JpaRepository<Categoria, Long> {

    List<Categoria> findAllByOrderByOrdemAscNomeAsc();

    Optional<Categoria> findByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCase(String nome);

    boolean existsByNomeIgnoreCaseAndIdNot(String nome, Long id);

    @Query(value = "SELECT COUNT(*) FROM artigo WHERE categoria_id = :id", nativeQuery = true)
    long contarArtigos(@Param("id") Long id);
}
