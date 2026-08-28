package br.unifebe.minhasaudefeminina.controller;

import br.unifebe.minhasaudefeminina.dto.SincronizacaoResponse;
import br.unifebe.minhasaudefeminina.service.SincronizacaoService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/sincronizacao")
public class SincronizacaoController {

    private final SincronizacaoService sincronizacaoService;

    public SincronizacaoController(SincronizacaoService sincronizacaoService) {
        this.sincronizacaoService = sincronizacaoService;
    }

    @GetMapping
    public SincronizacaoResponse sincronizar(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime desde) {
        return sincronizacaoService.sincronizar(desde);
    }
}
