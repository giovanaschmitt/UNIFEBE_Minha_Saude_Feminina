package br.unifebe.minhasaudefeminina.controller;

import br.unifebe.minhasaudefeminina.dto.ArtigoListaResponse;
import br.unifebe.minhasaudefeminina.dto.ArtigoRequest;
import br.unifebe.minhasaudefeminina.dto.ArtigoResponse;
import br.unifebe.minhasaudefeminina.dto.PublicacaoRequest;
import br.unifebe.minhasaudefeminina.service.ArtigoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.UriComponentsBuilder;

@RestController
@RequestMapping("/api/artigos")
public class ArtigoController {

    private final ArtigoService artigoService;

    public ArtigoController(ArtigoService artigoService) {
        this.artigoService = artigoService;
    }

    @GetMapping
    public ArtigoListaResponse listar(
            @RequestParam(required = false) String busca,
            @RequestParam(required = false) Long categoria_id,
            @RequestParam(required = false) String categoria,
            @RequestParam(required = false) String situacao,
            @RequestParam(required = false) Boolean publicado) {
        return artigoService.listar(busca, categoria_id, categoria, situacao, publicado);
    }

    @GetMapping("/{id}")
    public ArtigoResponse buscar(@PathVariable Long id) {
        return artigoService.buscar(id);
    }

    @PostMapping
    public ResponseEntity<ArtigoResponse> criar(@RequestBody @Valid ArtigoRequest dados,
                                                UriComponentsBuilder uriBuilder) {
        ArtigoResponse criado = artigoService.criar(dados);
        var uri = uriBuilder.path("/api/artigos/{id}").buildAndExpand(criado.id()).toUri();
        return ResponseEntity.created(uri).body(criado);
    }

    @PutMapping("/{id}")
    public ArtigoResponse atualizar(@PathVariable Long id, @RequestBody @Valid ArtigoRequest dados) {
        return artigoService.atualizar(id, dados);
    }

    @PatchMapping("/{id}/publicacao")
    public ArtigoResponse alternarPublicacao(@PathVariable Long id, @RequestBody @Valid PublicacaoRequest dados) {
        return artigoService.alternarPublicacao(id, dados.publicado());
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluir(@PathVariable Long id) {
        artigoService.excluir(id);
    }
}
