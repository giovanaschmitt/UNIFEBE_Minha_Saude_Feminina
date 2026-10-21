package br.unifebe.minhasaudefeminina.controller;

import br.unifebe.minhasaudefeminina.dto.SintomaCatalogoResponse;
import br.unifebe.minhasaudefeminina.dto.SintomaRequest;
import br.unifebe.minhasaudefeminina.dto.SintomaResponse;
import br.unifebe.minhasaudefeminina.service.SintomaService;
import com.google.firebase.auth.FirebaseToken;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/sintomas")
public class SintomaController {

    private final SintomaService sintomaService;

    public SintomaController(SintomaService sintomaService) {
        this.sintomaService = sintomaService;
    }

    @GetMapping("/catalogo")
    public List<SintomaCatalogoResponse> catalogo() {
        return sintomaService.catalogo();
    }

    @GetMapping
    public List<SintomaResponse> listar(@AuthenticationPrincipal FirebaseToken token) {
        return sintomaService.listar(token.getUid());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public SintomaResponse registrar(@AuthenticationPrincipal FirebaseToken token,
                                     @RequestBody @Valid SintomaRequest dados) {
        return sintomaService.registrar(token.getUid(), dados);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluir(@AuthenticationPrincipal FirebaseToken token, @PathVariable Long id) {
        sintomaService.excluir(token.getUid(), id);
    }
}
