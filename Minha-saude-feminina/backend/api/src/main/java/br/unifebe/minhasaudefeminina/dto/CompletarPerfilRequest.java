package br.unifebe.minhasaudefeminina.dto;

import java.time.LocalDate;

public record CompletarPerfilRequest(
        String nome,
        LocalDate dataNascimento,
        String faseVida
) {
}