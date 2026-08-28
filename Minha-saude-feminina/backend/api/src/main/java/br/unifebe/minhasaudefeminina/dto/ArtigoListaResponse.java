package br.unifebe.minhasaudefeminina.dto;

import java.util.List;

public record ArtigoListaResponse(int total, List<ArtigoResponse> artigos) {

    public static ArtigoListaResponse de(List<ArtigoResponse> artigos) {
        return new ArtigoListaResponse(artigos.size(), artigos);
    }
}
