package br.unifebe.minhasaudefeminina.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record CicloRequest(
        @NotNull(message = "Informe a data de início.")
        @JsonProperty("data_inicio") LocalDate dataInicio,
        @JsonProperty("data_fim") LocalDate dataFim,
        @Pattern(regexp = "(?i)leve|moderado|intenso", message = "O fluxo deve ser leve, moderado ou intenso.")
        String fluxo,
        @Size(max = 2000, message = "A observação deve ter até 2000 caracteres.") String observacao
) {
}
