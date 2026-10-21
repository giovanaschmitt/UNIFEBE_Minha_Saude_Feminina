package br.unifebe.minhasaudefeminina.dto;

import br.unifebe.minhasaudefeminina.model.CicloMenstrual;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDate;

public record CicloResponse(
        Long id,
        @JsonProperty("data_inicio") LocalDate dataInicio,
        @JsonProperty("data_fim") LocalDate dataFim,
        @JsonProperty("duracao_dias") Integer duracaoDias,
        String fluxo,
        String observacao
) {

    public static CicloResponse de(CicloMenstrual ciclo) {
        return new CicloResponse(
                ciclo.getId(),
                ciclo.getDataInicio(),
                ciclo.getDataFim(),
                ciclo.getDuracaoDias(),
                ciclo.getFluxo(),
                ciclo.getObservacao());
    }
}
