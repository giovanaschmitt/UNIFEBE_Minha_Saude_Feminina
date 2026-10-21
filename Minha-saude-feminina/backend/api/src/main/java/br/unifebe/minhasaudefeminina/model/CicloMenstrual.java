package br.unifebe.minhasaudefeminina.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

/**
 * Período menstrual registrado pela usuária (tabela CICLO_MENSTRUAL).
 * O banco permite um ciclo por usuária e data de início (UK_CICLO_INICIO).
 */
@Entity
@Table(name = "CICLO_MENSTRUAL")
public class CicloMenstrual {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "UID_USUARIA", nullable = false, length = 512)
    private String uidUsuaria;

    @Column(name = "DATA_INICIO", nullable = false)
    private LocalDate dataInicio;

    /** Nula enquanto o período está em andamento. */
    @Column(name = "DATA_FIM")
    private LocalDate dataFim;

    @Column(name = "DURACAO_DIAS")
    private Integer duracaoDias;

    /** leve, moderado ou intenso (CK_CICLO_FLUXO). */
    @Column(name = "FLUXO", length = 80)
    private String fluxo;

    @Column(name = "OBSERVACAO", length = 2000)
    private String observacao;

    @Column(name = "CRIADO_EM", nullable = false)
    private LocalDateTime criadoEm;

    @Column(name = "ATUALIZADO_EM", nullable = false)
    private LocalDateTime atualizadoEm;

    protected CicloMenstrual() {
    }

    public CicloMenstrual(String uidUsuaria) {
        this.uidUsuaria = uidUsuaria;
    }

    @PrePersist
    protected void aoCriar() {
        LocalDateTime agora = LocalDateTime.now();
        criadoEm = agora;
        atualizadoEm = agora;
        calcularDuracao();
    }

    @PreUpdate
    protected void aoAtualizar() {
        atualizadoEm = LocalDateTime.now();
        calcularDuracao();
    }

    private void calcularDuracao() {
        duracaoDias = dataFim == null ? null : (int) ChronoUnit.DAYS.between(dataInicio, dataFim) + 1;
    }

    public Long getId() {
        return id;
    }

    public String getUidUsuaria() {
        return uidUsuaria;
    }

    public LocalDate getDataInicio() {
        return dataInicio;
    }

    public void setDataInicio(LocalDate dataInicio) {
        this.dataInicio = dataInicio;
    }

    public LocalDate getDataFim() {
        return dataFim;
    }

    public void setDataFim(LocalDate dataFim) {
        this.dataFim = dataFim;
    }

    public Integer getDuracaoDias() {
        return duracaoDias;
    }

    public String getFluxo() {
        return fluxo;
    }

    public void setFluxo(String fluxo) {
        this.fluxo = fluxo;
    }

    public String getObservacao() {
        return observacao;
    }

    public void setObservacao(String observacao) {
        this.observacao = observacao;
    }

    public LocalDateTime getCriadoEm() {
        return criadoEm;
    }

    public LocalDateTime getAtualizadoEm() {
        return atualizadoEm;
    }
}
