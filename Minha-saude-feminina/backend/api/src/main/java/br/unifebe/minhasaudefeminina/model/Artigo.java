package br.unifebe.minhasaudefeminina.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.text.Normalizer;
import java.time.LocalDateTime;

@Entity
@Table(name = "ARTIGO")
public class Artigo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "TITULO", nullable = false, length = 160)
    private String titulo;

    @Column(name = "SLUG", nullable = false, length = 180, unique = true)
    private String slug;

    @Column(name = "RESUMO", nullable = false, length = 300)
    private String resumo = " ";

    @Lob
    @Column(name = "CONTEUDO_HTML", nullable = false)
    private String conteudoHtml;

    @Column(name = "CAPA_URL", length = 400)
    private String capaUrl;

    @Column(name = "EMOJI", nullable = false, length = 16)
    private String emoji = "💗";

    @Column(name = "AUTORA", nullable = false, length = 120)
    private String autora = "Equipe editorial";

    @Column(name = "TEMPO_LEITURA", nullable = false)
    private Integer tempoLeitura = 3;

    @Column(name = "PUBLICADO", nullable = false)
    private boolean publicado = true;

    @Column(name = "DESTAQUE", nullable = false)
    private boolean destaque = false;

    @Column(name = "VISUALIZACOES", nullable = false)
    private long visualizacoes = 0;

    @Column(name = "CRIADO_EM", nullable = false)
    private LocalDateTime criadoEm;

    @Column(name = "ATUALIZADO_EM", nullable = false)
    private LocalDateTime atualizadoEm;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "CATEGORIA_ID", nullable = false)
    private Categoria categoria;

    public Artigo() {
    }

    @PrePersist
    protected void aoCriar() {
        LocalDateTime agora = LocalDateTime.now();
        criadoEm = agora;
        atualizadoEm = agora;
        if (slug == null || slug.isBlank()) {
            slug = slugDeEmergencia(titulo);
        }
    }

    @PreUpdate
    protected void aoAtualizar() {
        atualizadoEm = LocalDateTime.now();
        if (slug == null || slug.isBlank()) {
            slug = slugDeEmergencia(titulo);
        }
    }

    private static String slugDeEmergencia(String titulo) {
        String base = (titulo == null || titulo.isBlank()) ? "artigo" : titulo;
        String semAcentos = Normalizer.normalize(base, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        String gerado = semAcentos.toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-+|-+$", "");
        if (gerado.isEmpty()) {
            gerado = "artigo";
        }
        if (gerado.length() > 160) {
            gerado = gerado.substring(0, 160);
        }
        return gerado + "-" + (System.currentTimeMillis() % 100000);
    }

    public Long getId() {
        return id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getResumo() {
        return resumo;
    }

    public void setResumo(String resumo) {
        this.resumo = resumo;
    }

    public String getConteudoHtml() {
        return conteudoHtml;
    }

    public void setConteudoHtml(String conteudoHtml) {
        this.conteudoHtml = conteudoHtml;
    }

    public String getCapaUrl() {
        return capaUrl;
    }

    public void setCapaUrl(String capaUrl) {
        this.capaUrl = capaUrl;
    }

    public String getEmoji() {
        return emoji;
    }

    public void setEmoji(String emoji) {
        this.emoji = emoji;
    }

    public String getAutora() {
        return autora;
    }

    public void setAutora(String autora) {
        this.autora = autora;
    }

    public Integer getTempoLeitura() {
        return tempoLeitura;
    }

    public void setTempoLeitura(Integer tempoLeitura) {
        this.tempoLeitura = tempoLeitura;
    }

    public boolean isPublicado() {
        return publicado;
    }

    public void setPublicado(boolean publicado) {
        this.publicado = publicado;
    }

    public boolean isDestaque() {
        return destaque;
    }

    public void setDestaque(boolean destaque) {
        this.destaque = destaque;
    }

    public long getVisualizacoes() {
        return visualizacoes;
    }

    public LocalDateTime getCriadoEm() {
        return criadoEm;
    }

    public LocalDateTime getAtualizadoEm() {
        return atualizadoEm;
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }
}
