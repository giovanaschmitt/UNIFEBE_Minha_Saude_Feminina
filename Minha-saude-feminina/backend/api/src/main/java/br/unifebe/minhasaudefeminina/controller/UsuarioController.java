package br.unifebe.minhasaudefeminina.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.google.firebase.auth.FirebaseToken;

import br.unifebe.minhasaudefeminina.dto.CompletarPerfilRequest;
import br.unifebe.minhasaudefeminina.model.Usuaria;
import br.unifebe.minhasaudefeminina.service.UsuarioSyncService;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioSyncService usuarioSyncService;

    public UsuarioController(UsuarioSyncService usuarioSyncService) {
        this.usuarioSyncService = usuarioSyncService;
    }

   
    @GetMapping("/me")
    public Usuaria meuPerfil(@AuthenticationPrincipal FirebaseToken token) {
        return usuarioSyncService.buscarOuCriar(token);
    }

   
    @PutMapping("/me")
    public Usuaria completarPerfil(
            @AuthenticationPrincipal FirebaseToken token,
            @RequestBody CompletarPerfilRequest dados) {
        return usuarioSyncService.completarPerfil(token, dados);
    }
}