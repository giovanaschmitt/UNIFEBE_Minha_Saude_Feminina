package br.unifebe.minhasaudefeminina.dto;

import br.unifebe.minhasaudefeminina.model.RegistroSintoma;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record SintomaResponse(
        Long id,
        @JsonProperty("sintoma_id") Long sintomaId,
        String sintoma,
        String intensidade,
        String observacao,
        @JsonProperty("data_registro") LocalDate dataRegistro,
        @JsonProperty("criado_em")
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss") LocalDateTime criadoEm
) {

    public static SintomaResponse de(RegistroSintoma registro) {
        String intensidade = registro.getIntensidade();
        return new SintomaResponse(
                registro.getId(),
                registro.getSintoma().getId(),
                registro.getSintoma().getNome(),
                intensidade.substring(0, 1).toUpperCase() + intensidade.substring(1),
                registro.getObservacao(),
                registro.getDataRegistro(),
                registro.getCriadoEm());
    }
}
