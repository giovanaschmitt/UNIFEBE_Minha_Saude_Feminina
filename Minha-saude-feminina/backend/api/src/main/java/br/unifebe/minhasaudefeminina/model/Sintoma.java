package br.unifebe.minhasaudefeminina.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** Catálogo de sintomas que a usuária pode registrar (tabela SINTOMA). */
@Entity
@Table(name = "SINTOMA")
public class Sintoma {

    @Id
    @Column(name = "ID")
    private Long id;

    @Column(name = "NOME", nullable = false, length = 320)
    private String nome;

    @Column(name = "EMOJI", nullable = false, length = 64)
    private String emoji;

    @Column(name = "GRUPO", length = 160)
    private String grupo;

    @Column(name = "ORDEM", nullable = false)
    private Integer ordem;

    @Column(name = "ATIVO", nullable = false)
    private boolean ativo;

    protected Sintoma() {
    }

    public Long getId() {
        return id;
    }

    public String getNome() {
        return nome;
    }

    public String getEmoji() {
        return emoji;
    }

    public String getGrupo() {
        return grupo;
    }

    public Integer getOrdem() {
        return ordem;
    }

    public boolean isAtivo() {
        return ativo;
    }
}
