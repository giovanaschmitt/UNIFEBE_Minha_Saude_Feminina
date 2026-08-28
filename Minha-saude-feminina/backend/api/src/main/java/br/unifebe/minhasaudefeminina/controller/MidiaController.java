package br.unifebe.minhasaudefeminina.controller;

import br.unifebe.minhasaudefeminina.dto.MidiaResponse;
import br.unifebe.minhasaudefeminina.service.MidiaService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

@RestController
@RequestMapping("/api/midia")
public class MidiaController {

    private final MidiaService midiaService;

    public MidiaController(MidiaService midiaService) {
        this.midiaService = midiaService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public MidiaResponse enviar(@RequestParam("arquivo") MultipartFile arquivo, HttpServletRequest request) {
        String baseUrl = ServletUriComponentsBuilder.fromContextPath(request).toUriString();
        String url = midiaService.salvar(arquivo, baseUrl);
        return new MidiaResponse(url);
    }
}
