package br.unifebe.minhasaudefeminina.controller;

import br.unifebe.minhasaudefeminina.dto.CicloRequest;
import br.unifebe.minhasaudefeminina.dto.CicloResponse;
import br.unifebe.minhasaudefeminina.service.CicloService;
import com.google.firebase.auth.FirebaseToken;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/ciclos")
public class CicloController {

    private final CicloService cicloService;

    public CicloController(CicloService cicloService) {
        this.cicloService = cicloService;
    }

    @GetMapping
    public List<CicloResponse> listar(@AuthenticationPrincipal FirebaseToken token) {
        return cicloService.listar(token.getUid());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CicloResponse criar(@AuthenticationPrincipal FirebaseToken token,
                               @RequestBody @Valid CicloRequest dados) {
        return cicloService.criar(token.getUid(), dados);
    }

    @PutMapping("/{id}")
    public CicloResponse atualizar(@AuthenticationPrincipal FirebaseToken token,
                                   @PathVariable Long id,
                                   @RequestBody @Valid CicloRequest dados) {
        return cicloService.atualizar(token.getUid(), id, dados);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluir(@AuthenticationPrincipal FirebaseToken token, @PathVariable Long id) {
        cicloService.excluir(token.getUid(), id);
    }
}
