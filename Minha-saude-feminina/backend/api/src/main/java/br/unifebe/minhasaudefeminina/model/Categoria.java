package br.unifebe.minhasaudefeminina.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "CATEGORIA")
public class Categoria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "NOME", nullable = false, length = 60, unique = true)
    private String nome;

    @Column(name = "EMOJI", nullable = false, length = 16)
    private String emoji = "💗";

    @Column(name = "COR", nullable = false, length = 9)
    private String cor = "#B81E4D";

    @Column(name = "ORDEM", nullable = false)
    private Integer ordem = 0;

    public Categoria() {
    }

    public Categoria(String nome, String emoji, String cor, Integer ordem) {
        this.nome = nome;
        this.emoji = emoji;
        this.cor = cor;
        this.ordem = ordem;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getEmoji() {
        return emoji;
    }

    public void setEmoji(String emoji) {
        this.emoji = emoji;
    }

    public String getCor() {
        return cor;
    }

    public void setCor(String cor) {
        this.cor = cor;
    }

    public Integer getOrdem() {
        return ordem;
    }

    public void setOrdem(Integer ordem) {
        this.ordem = ordem;
    }
}
