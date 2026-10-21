package br.unifebe.minhasaudefeminina.dao;

import br.unifebe.minhasaudefeminina.model.DispositivoNotificacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface DispositivoNotificacaoDao extends JpaRepository<DispositivoNotificacao, Long> {

    Optional<DispositivoNotificacao> findByToken(String token);

    Optional<DispositivoNotificacao> findByTokenAndUidUsuaria(String token, String uidUsuaria);

    List<DispositivoNotificacao> findAllByUidUsuaria(String uidUsuaria);

    List<DispositivoNotificacao> findAllByLembreteCicloTrue();

    void deleteAllByTokenIn(Collection<String> tokens);
}
