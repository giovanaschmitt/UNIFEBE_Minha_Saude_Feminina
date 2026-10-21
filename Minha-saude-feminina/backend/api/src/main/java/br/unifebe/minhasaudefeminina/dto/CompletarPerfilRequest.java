package br.unifebe.minhasaudefeminina.dto;

import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

/**
 * Campos nulos não são alterados. Fases da vida aceitas (até 20 caracteres, coluna FASE_VIDA):
 * adolescencia, idade_fertil, gestante, pos_parto, climaterio, menopausa.
 */
public record CompletarPerfilRequest(
        @Size(max = 100, message = "O nome deve ter até 100 caracteres.") String nome,
        @Past(message = "A data de nascimento deve estar no passado.") LocalDate dataNascimento,
        @Pattern(regexp = "adolescencia|idade_fertil|gestante|pos_parto|climaterio|menopausa",
                message = "Fase da vida inválida.") String faseVida
) {
}
