package br.unifebe.minhasaudefeminina.controller;

import br.unifebe.minhasaudefeminina.dto.DispositivoRequest;
import br.unifebe.minhasaudefeminina.service.NotificacaoService;
import com.google.firebase.auth.FirebaseToken;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/notificacoes")
public class NotificacaoController {

    private final NotificacaoService notificacaoService;

    public NotificacaoController(NotificacaoService notificacaoService) {
        this.notificacaoService = notificacaoService;
    }

    @PutMapping("/dispositivo")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void registrar(@AuthenticationPrincipal FirebaseToken token,
                          @RequestBody @Valid DispositivoRequest dados) {
        notificacaoService.registrar(token.getUid(), dados);
    }

    @DeleteMapping("/dispositivo")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void remover(@AuthenticationPrincipal FirebaseToken token, @RequestParam("token") String tokenAparelho) {
        notificacaoService.remover(token.getUid(), tokenAparelho);
    }

    @PostMapping("/teste")
    public Map<String, Integer> enviarTeste(@AuthenticationPrincipal FirebaseToken token) {
        return Map.of("enviadas", notificacaoService.enviarTeste(token.getUid()));
    }
}
