package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.model.CicloMenstrual;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

/**
 * Previsão do próximo período, com a mesma regra do app (CycleService):
 * início do último período + média de dias entre inícios consecutivos (28 sem histórico).
 */
public final class PrevisaoCiclo {

    public static final int DURACAO_PADRAO = 28;

    private PrevisaoCiclo() {
    }

    public static Optional<LocalDate> proximoInicio(List<CicloMenstrual> ciclos) {
        List<LocalDate> inicios = ciclos.stream()
                .map(CicloMenstrual::getDataInicio)
                .sorted(Comparator.naturalOrder())
                .toList();
        if (inicios.isEmpty()) {
            return Optional.empty();
        }

        long soma = 0;
        int intervalos = 0;
        for (int i = 1; i < inicios.size(); i++) {
            long dias = ChronoUnit.DAYS.between(inicios.get(i - 1), inicios.get(i));
            if (dias > 0) {
                soma += dias;
                intervalos++;
            }
        }
        long duracao = intervalos == 0 ? DURACAO_PADRAO : Math.round((double) soma / intervalos);
        return Optional.of(inicios.get(inicios.size() - 1).plusDays(duracao));
    }
}
