package br.unifebe.minhasaudefeminina.dao;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import br.unifebe.minhasaudefeminina.model.Usuaria;

public interface UsuariaRepository extends JpaRepository<Usuaria, Long> {
    Optional<Usuaria> findByFirebaseUid(String firebaseUid);
}