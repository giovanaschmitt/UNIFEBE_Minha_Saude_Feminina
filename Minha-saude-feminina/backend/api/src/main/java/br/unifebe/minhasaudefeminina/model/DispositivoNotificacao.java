package br.unifebe.minhasaudefeminina.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

/** Aparelho que recebe notificações push via FCM (tabela DISPOSITIVO_NOTIFICACAO). */
@Entity
@Table(name = "DISPOSITIVO_NOTIFICACAO")
public class DispositivoNotificacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "UID_USUARIA", nullable = false, length = 512)
    private String uidUsuaria;

    @Column(name = "TOKEN", nullable = false, length = 512, unique = true)
    private String token;

    @Column(name = "PLATAFORMA", length = 20)
    private String plataforma;

    @Column(name = "LEMBRETE_CICLO", nullable = false)
    private boolean lembreteCiclo = true;

    @Column(name = "CRIADO_EM", nullable = false)
    private LocalDateTime criadoEm;

    @Column(name = "ATUALIZADO_EM", nullable = false)
    private LocalDateTime atualizadoEm;

    protected DispositivoNotificacao() {
    }

    public DispositivoNotificacao(String token) {
        this.token = token;
    }

    @PrePersist
    protected void aoCriar() {
        LocalDateTime agora = LocalDateTime.now();
        criadoEm = agora;
        atualizadoEm = agora;
    }

    @PreUpdate
    protected void aoAtualizar() {
        atualizadoEm = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public String getUidUsuaria() {
        return uidUsuaria;
    }

    public void setUidUsuaria(String uidUsuaria) {
        this.uidUsuaria = uidUsuaria;
    }

    public String getToken() {
        return token;
    }

    public String getPlataforma() {
        return plataforma;
    }

    public void setPlataforma(String plataforma) {
        this.plataforma = plataforma;
    }

    public boolean isLembreteCiclo() {
        return lembreteCiclo;
    }

    public void setLembreteCiclo(boolean lembreteCiclo) {
        this.lembreteCiclo = lembreteCiclo;
    }
}
