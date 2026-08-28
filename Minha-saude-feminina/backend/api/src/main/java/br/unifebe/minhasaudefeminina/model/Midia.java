package br.unifebe.minhasaudefeminina.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "MIDIA")
public class Midia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "NOME_ORIGINAL", nullable = false, length = 255)
    private String nomeOriginal;

    @Column(name = "NOME_ARQUIVO", nullable = false, length = 120, unique = true)
    private String nomeArquivo;

    @Column(name = "URL", nullable = false, length = 400)
    private String url;

    @Column(name = "TIPO_MIME", nullable = false, length = 100)
    private String tipoMime;

    @Column(name = "TAMANHO_BYTES", nullable = false)
    private long tamanhoBytes;

    @Column(name = "LARGURA_PX")
    private Integer larguraPx;

    @Column(name = "ALTURA_PX")
    private Integer alturaPx;

    @Column(name = "ENVIADO_POR", length = 128)
    private String enviadoPor;

    @Column(name = "ENVIADO_EM", nullable = false)
    private LocalDateTime enviadoEm;

    public Midia() {
    }

    @PrePersist
    protected void aoCriar() {
        enviadoEm = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public String getNomeOriginal() {
        return nomeOriginal;
    }

    public void setNomeOriginal(String nomeOriginal) {
        this.nomeOriginal = nomeOriginal;
    }

    public String getNomeArquivo() {
        return nomeArquivo;
    }

    public void setNomeArquivo(String nomeArquivo) {
        this.nomeArquivo = nomeArquivo;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getTipoMime() {
        return tipoMime;
    }

    public void setTipoMime(String tipoMime) {
        this.tipoMime = tipoMime;
    }

    public long getTamanhoBytes() {
        return tamanhoBytes;
    }

    public void setTamanhoBytes(long tamanhoBytes) {
        this.tamanhoBytes = tamanhoBytes;
    }

    public Integer getLarguraPx() {
        return larguraPx;
    }

    public void setLarguraPx(Integer larguraPx) {
        this.larguraPx = larguraPx;
    }

    public Integer getAlturaPx() {
        return alturaPx;
    }

    public void setAlturaPx(Integer alturaPx) {
        this.alturaPx = alturaPx;
    }

    public String getEnviadoPor() {
        return enviadoPor;
    }

    public void setEnviadoPor(String enviadoPor) {
        this.enviadoPor = enviadoPor;
    }

    public LocalDateTime getEnviadoEm() {
        return enviadoEm;
    }
}
