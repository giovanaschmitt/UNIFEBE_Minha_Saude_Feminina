package br.unifebe.minhasaudefeminina.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record DispositivoRequest(
        @NotBlank(message = "Informe o token do aparelho.")
        @Size(max = 512, message = "Token inválido.") String token,
        @Size(max = 20, message = "Plataforma inválida.") String plataforma,
        @JsonProperty("lembrete_ciclo") Boolean lembreteCiclo
) {
}
