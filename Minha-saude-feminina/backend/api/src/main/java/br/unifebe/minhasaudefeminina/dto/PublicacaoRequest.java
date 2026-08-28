package br.unifebe.minhasaudefeminina.dto;

import jakarta.validation.constraints.NotNull;

public record PublicacaoRequest(
        @NotNull(message = "Informe o campo \"publicado\".") Boolean publicado
) {
}
