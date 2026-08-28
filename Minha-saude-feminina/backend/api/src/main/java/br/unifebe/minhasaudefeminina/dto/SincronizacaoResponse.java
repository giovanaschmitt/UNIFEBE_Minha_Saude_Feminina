package br.unifebe.minhasaudefeminina.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDateTime;
import java.util.List;

public record SincronizacaoResponse(
        @JsonProperty("servidor_em")
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss") LocalDateTime servidorEm,
        List<ArtigoResponse> atualizados,
        List<Long> removidos
) {
}
