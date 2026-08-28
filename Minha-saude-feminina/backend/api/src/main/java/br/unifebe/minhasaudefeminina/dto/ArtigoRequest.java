package br.unifebe.minhasaudefeminina.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record ArtigoRequest(
        @NotBlank(message = "Informe o título do artigo.") String titulo,
        String resumo,
        @NotBlank(message = "Escreva o conteúdo do artigo.")
        @JsonProperty("conteudo_html") String conteudoHtml,
        String emoji,
        @JsonProperty("capa_url") String capaUrl,
        String autora,
        @JsonProperty("tempo_leitura") Integer tempoLeitura,
        Boolean publicado,
        Boolean destaque,
        @NotNull(message = "Selecione uma categoria.")
        @JsonProperty("categoria_id") Long categoriaId
) {
}
