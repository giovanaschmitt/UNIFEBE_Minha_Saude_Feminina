package br.unifebe.minhasaudefeminina.dto;

import br.unifebe.minhasaudefeminina.model.Categoria;

public record CategoriaResponse(
        Long id,
        String nome,
        String emoji,
        String cor,
        Integer ordem
) {

    public static CategoriaResponse de(Categoria categoria) {
        return new CategoriaResponse(
                categoria.getId(),
                categoria.getNome(),
                categoria.getEmoji(),
                categoria.getCor(),
                categoria.getOrdem());
    }
}
