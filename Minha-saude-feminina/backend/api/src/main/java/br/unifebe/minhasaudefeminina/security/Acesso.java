package br.unifebe.minhasaudefeminina.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class Acesso {

    private Acesso() {
    }

    public static boolean ehAdmin() {
        Authentication autenticacao = SecurityContextHolder.getContext().getAuthentication();
        return autenticacao != null && autenticacao.getAuthorities().stream()
                .anyMatch(papel -> FirebaseTokenFilter.PAPEL_ADMIN.equals(papel.getAuthority()));
    }
}
