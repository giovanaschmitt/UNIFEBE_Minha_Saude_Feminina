package br.unifebe.minhasaudefeminina.dto;

import br.unifebe.minhasaudefeminina.model.Sintoma;

public record SintomaCatalogoResponse(Long id, String nome, String emoji, String grupo) {

    public static SintomaCatalogoResponse de(Sintoma sintoma) {
        return new SintomaCatalogoResponse(sintoma.getId(), sintoma.getNome(), sintoma.getEmoji(), sintoma.getGrupo());
    }
}
