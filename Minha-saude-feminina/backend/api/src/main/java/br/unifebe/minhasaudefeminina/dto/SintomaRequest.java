package br.unifebe.minhasaudefeminina.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record SintomaRequest(
        @NotBlank(message = "Informe o sintoma.") String sintoma,
        @NotBlank(message = "Informe a intensidade.")
        @Pattern(regexp = "(?i)leve|moderada|forte", message = "A intensidade deve ser Leve, Moderada ou Forte.")
        String intensidade,
        @Size(max = 2000, message = "A observação deve ter até 2000 caracteres.") String observacao,
        @JsonProperty("data_registro") LocalDate dataRegistro
) {
}
