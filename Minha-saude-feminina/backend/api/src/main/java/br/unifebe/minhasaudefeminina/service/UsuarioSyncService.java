package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.dto.CompletarPerfilRequest;
import br.unifebe.minhasaudefeminina.model.Usuaria;
import br.unifebe.minhasaudefeminina.dao.UsuariaRepository;
import br.unifebe.minhasaudefeminina.exception.ConflitoException;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.stereotype.Service;

@Service
public class UsuarioSyncService {

    private final UsuariaRepository usuariaRepository;

    public UsuarioSyncService(UsuariaRepository usuariaRepository) {
        this.usuariaRepository = usuariaRepository;
    }

   
    public Usuaria buscarOuCriar(FirebaseToken token) {
        return usuariaRepository.findByFirebaseUid(token.getUid())
                .orElseGet(() -> vincularOuCriar(token));
    }

    // Se a conta Firebase for recriada (ex.: troca de projeto), o e-mail continua
    // o mesmo mas o UID muda; reaproveita o registro em vez de violar o e-mail único.
    private Usuaria vincularOuCriar(FirebaseToken token) {
        if (token.getEmail() != null) {
            var existente = usuariaRepository.findByEmailIgnoreCase(token.getEmail());
            if (existente.isPresent()) {
                // Sem e-mail confirmado, qualquer pessoa poderia assumir o perfil de outra.
                if (!token.isEmailVerified()) {
                    throw new ConflitoException("Já existe um perfil com este e-mail. Confirme o e-mail da conta para recuperá-lo.");
                }
                Usuaria usuaria = existente.get();
                usuaria.vincularFirebase(token.getUid());
                return usuariaRepository.save(usuaria);
            }
        }
        return usuariaRepository.save(new Usuaria(token.getUid(), token.getEmail()));
    }

    public Usuaria completarPerfil(FirebaseToken token, CompletarPerfilRequest dados) {
        Usuaria usuaria = buscarOuCriar(token);
        if (dados.nome() != null && !dados.nome().isBlank()) {
            usuaria.setNome(dados.nome().trim());
        }
        if (dados.dataNascimento() != null) {
            usuaria.setDataNascimento(dados.dataNascimento());
        }
        if (dados.faseVida() != null && !dados.faseVida().isBlank()) {
            usuaria.setFaseVida(dados.faseVida().trim());
        }
        return usuariaRepository.save(usuaria);
    }
}