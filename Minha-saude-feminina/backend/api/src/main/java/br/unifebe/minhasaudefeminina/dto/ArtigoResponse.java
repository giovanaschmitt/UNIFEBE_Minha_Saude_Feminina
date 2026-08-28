package br.unifebe.minhasaudefeminina.dto;

import br.unifebe.minhasaudefeminina.model.Artigo;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDateTime;

public record ArtigoResponse(
        Long id,
        String titulo,
        String slug,
        String resumo,
        @JsonProperty("conteudo_html") String conteudoHtml,
        String emoji,
        @JsonProperty("capa_url") String capaUrl,
        String autora,
        @JsonProperty("tempo_leitura") Integer tempoLeitura,
        Boolean publicado,
        Boolean destaque,
        @JsonProperty("categoria_id") Long categoriaId,
        String categoria,
        @JsonProperty("categoria_emoji") String categoriaEmoji,
        @JsonProperty("categoria_cor") String categoriaCor,
        @JsonProperty("criado_em")
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss") LocalDateTime criadoEm,
        @JsonProperty("atualizado_em")
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss") LocalDateTime atualizadoEm
) {

    public static ArtigoResponse completo(Artigo artigo) {
        return montar(artigo, artigo.getConteudoHtml());
    }

    public static ArtigoResponse resumo(Artigo artigo) {
        return montar(artigo, null);
    }

    private static ArtigoResponse montar(Artigo artigo, String conteudoHtml) {
        return new ArtigoResponse(
                artigo.getId(),
                artigo.getTitulo(),
                artigo.getSlug(),
                artigo.getResumo(),
                conteudoHtml,
                artigo.getEmoji(),
                artigo.getCapaUrl(),
                artigo.getAutora(),
                artigo.getTempoLeitura(),
                artigo.isPublicado(),
                artigo.isDestaque(),
                artigo.getCategoria().getId(),
                artigo.getCategoria().getNome(),
                artigo.getCategoria().getEmoji(),
                artigo.getCategoria().getCor(),
                artigo.getCriadoEm(),
                artigo.getAtualizadoEm());
    }
}
