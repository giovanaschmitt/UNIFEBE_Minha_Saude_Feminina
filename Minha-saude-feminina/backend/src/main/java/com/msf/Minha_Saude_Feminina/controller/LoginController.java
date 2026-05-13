package com.complexo.UNIFEBE_Complexo_Esportivo.controller;

import com.complexo.UNIFEBE_Complexo_Esportivo.service.LoginService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/login")
@CrossOrigin(origins = "*")
public class LoginController {

    private final LoginService service;

    public LoginController(LoginService service) {
        this.service = service;
    }

    @GetMapping("/validar/{matricula}/{senha}")
    public ResponseEntity<String> verificar(
            @PathVariable int matricula,
            @PathVariable String senha) {

        return service.validarEntrada(matricula, senha)
                ? ResponseEntity.ok("Entrada validada com sucesso!")
                : ResponseEntity.badRequest().body("Credenciais inválidas!");
    }

}
