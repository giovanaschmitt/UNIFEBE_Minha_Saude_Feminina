package br.unifebe.minhasaudefeminina.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Sintoma registrado pela usuária em um dia (tabela REGISTRO_SINTOMA).
 * O banco permite um registro por usuária, sintoma e dia (UK_REGISTRO_SINTOMA_DIA).
 */
@Entity
@Table(name = "REGISTRO_SINTOMA")
public class RegistroSintoma {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "UID_USUARIA", nullable = false, length = 512)
    private String uidUsuaria;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "SINTOMA_ID", nullable = false)
    private Sintoma sintoma;

    @Column(name = "DATA_REGISTRO", nullable = false)
    private LocalDate dataRegistro;

    /** Gravada em minúsculas: leve, moderada ou forte (CK_REGISTRO_INTENSIDADE). */
    @Column(name = "INTENSIDADE", nullable = false, length = 80)
    private String intensidade;

    @Column(name = "OBSERVACAO", length = 2000)
    private String observacao;

    @Column(name = "CICLO_ID")
    private Long cicloId;

    @Column(name = "CRIADO_EM", nullable = false)
    private LocalDateTime criadoEm;

    protected RegistroSintoma() {
    }

    public RegistroSintoma(String uidUsuaria, Sintoma sintoma, LocalDate dataRegistro) {
        this.uidUsuaria = uidUsuaria;
        this.sintoma = sintoma;
        this.dataRegistro = dataRegistro;
    }

    @PrePersist
    protected void aoCriar() {
        criadoEm = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public String getUidUsuaria() {
        return uidUsuaria;
    }

    public Sintoma getSintoma() {
        return sintoma;
    }

    public LocalDate getDataRegistro() {
        return dataRegistro;
    }

    public String getIntensidade() {
        return intensidade;
    }

    public void setIntensidade(String intensidade) {
        this.intensidade = intensidade;
    }

    public String getObservacao() {
        return observacao;
    }

    public void setObservacao(String observacao) {
        this.observacao = observacao;
    }

    public Long getCicloId() {
        return cicloId;
    }

    public LocalDateTime getCriadoEm() {
        return criadoEm;
    }
}
