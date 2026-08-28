package br.unifebe.minhasaudefeminina.dto;

import jakarta.validation.constraints.NotBlank;

public record CategoriaRequest(
        @NotBlank(message = "Informe o nome da categoria.") String nome,
        String emoji,
        String cor,
        Integer ordem
) {
}
