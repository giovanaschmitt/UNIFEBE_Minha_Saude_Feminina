package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.dto.CompletarPerfilRequest;
import br.unifebe.minhasaudefeminina.model.Usuaria;
import br.unifebe.minhasaudefeminina.dao.UsuariaRepository;
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
                .orElseGet(() -> usuariaRepository.save(
                        new Usuaria(token.getUid(), token.getEmail())
                ));
    }

    public Usuaria completarPerfil(FirebaseToken token, CompletarPerfilRequest dados) {
        Usuaria usuaria = buscarOuCriar(token);
        usuaria.setNome(dados.nome());
        usuaria.setDataNascimento(dados.dataNascimento());
        usuaria.setFaseVida(dados.faseVida());
        return usuariaRepository.save(usuaria);
    }
}