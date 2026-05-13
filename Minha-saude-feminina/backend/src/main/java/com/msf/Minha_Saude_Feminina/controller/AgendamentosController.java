package com.complexo.UNIFEBE_Complexo_Esportivo.controller;

import com.complexo.UNIFEBE_Complexo_Esportivo.dao.Agendamentos;
import com.complexo.UNIFEBE_Complexo_Esportivo.service.AgendamentosService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
@RequestMapping("/api/agendamentos")
@CrossOrigin(origins = "*")
public class AgendamentosController {

    private final AgendamentosService service;

    public AgendamentosController(AgendamentosService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<String> criar(@RequestBody Agendamentos a) {
        int res = service.inserirAgendamento(a);
        return res > 0 ? ResponseEntity.ok("OK") : ResponseEntity.status(500).body("Erro");
    }

    @PutMapping("/{id}/cancelar")
    public ResponseEntity<String> cancelar(@PathVariable int id) {
        int res = service.cancelarAgendamento(id);
        return res > 0 ? ResponseEntity.ok("OK") : ResponseEntity.status(404).body("Não encontrado/erro");
    }

    @GetMapping("/usuario/{id}")
    public ArrayList<Agendamentos> porUsuario(@PathVariable int id) {
        return service.consultarAgendamentosUsuario(id);
    }

    @GetMapping("/usuario/{id}/futuros")
    public ArrayList<Agendamentos> porUsuarioFuturos(@PathVariable int id) {
        return service.consultarAgendamentosUsuarioFuturos(id);
    }

    @GetMapping("/ambiente/{id}")
    public ArrayList<Agendamentos> porAmbiente(@PathVariable int id) {
        return service.consultarAgendamentosAmbiente(id);
    }

    @GetMapping("/ambiente/{id}/futuros")
    public ArrayList<Agendamentos> porAmbienteFuturos(@PathVariable int id) {
        return service.consultarAgendamentosAmbienteFuturos(id);
    }

}
