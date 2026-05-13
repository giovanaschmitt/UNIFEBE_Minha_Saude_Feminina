package com.complexo.UNIFEBE_Complexo_Esportivo.controller;

import com.complexo.UNIFEBE_Complexo_Esportivo.dao.Usuario;
import com.complexo.UNIFEBE_Complexo_Esportivo.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    private final UsuarioService service;

    public UsuarioController(UsuarioService service) {
        this.service = service;
    }

    @GetMapping
    public ArrayList<Usuario> listar() {
        return service.listarTodos();
    }

    @GetMapping("/{tipo}")
    public ArrayList<Usuario> listarPorTipo(@PathVariable char tipo) {
        return service.listarPorTipo(tipo);
    }

    @GetMapping("/{matricula}")
    public ResponseEntity<Usuario> buscar(@PathVariable int matricula) {
        Usuario u = service.buscarPorMatricula(matricula);
        return u == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(u);
    }

    @GetMapping("/nome/{nome}")
    public ArrayList<Usuario> buscarPorNome(@PathVariable String nome) {
        return service.buscarPorNome(nome);
    }

    @PostMapping
    public ResponseEntity<String> criar(@RequestBody Usuario usuario) {
        int res = service.inserir(usuario);
        return res > 0 ? ResponseEntity.ok("OK") : ResponseEntity.status(500).body("Erro ao inserir");
    }

    @DeleteMapping("/{matricula}")
    public ResponseEntity<String> remover(@PathVariable int matricula) {
        int res = service.removerPorMatricula(matricula);
        return res > 0 ? ResponseEntity.ok("OK") : ResponseEntity.status(404).body("Não encontrado/erro");
    }
}
