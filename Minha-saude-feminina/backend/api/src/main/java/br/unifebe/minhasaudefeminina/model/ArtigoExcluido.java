package br.unifebe.minhasaudefeminina.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "ARTIGO_EXCLUIDO")
public class ArtigoExcluido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "ARTIGO_ID", nullable = false)
    private Long artigoId;

    @Column(name = "TITULO", nullable = false, length = 160)
    private String titulo;

    @Column(name = "EXCLUIDO_EM", nullable = false)
    private LocalDateTime excluidoEm;

    @Column(name = "EXCLUIDO_POR", length = 128)
    private String excluidoPor;

    public ArtigoExcluido() {
    }

    public ArtigoExcluido(Long artigoId, String titulo) {
        this(artigoId, titulo, null);
    }

    public ArtigoExcluido(Long artigoId, String titulo, String excluidoPor) {
        this.artigoId = artigoId;
        this.titulo = titulo;
        this.excluidoEm = LocalDateTime.now();
        this.excluidoPor = excluidoPor;
    }

    public Long getId() {
        return id;
    }

    public Long getArtigoId() {
        return artigoId;
    }

    public String getTitulo() {
        return titulo;
    }

    public LocalDateTime getExcluidoEm() {
        return excluidoEm;
    }

    public String getExcluidoPor() {
        return excluidoPor;
    }
}
