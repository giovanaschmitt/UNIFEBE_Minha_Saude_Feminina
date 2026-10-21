package br.unifebe.minhasaudefeminina.security;

import java.io.IOException;
import java.util.List;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class FirebaseTokenFilter extends OncePerRequestFilter {

    public static final String CLAIM_ADMIN = "admin";
    public static final String PAPEL_ADMIN = "ROLE_ADMIN";

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws IOException, ServletException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);

        try {
            FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(token);

            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(decoded, null, papeis(decoded));
            SecurityContextHolder.getContext().setAuthentication(authentication);

            filterChain.doFilter(request, response);
        } catch (FirebaseAuthException e) {
            System.out.println("Falha ao validar token Firebase: " + e.getAuthErrorCode() + " - " + e.getMessage());
            SecurityContextHolder.clearContext();
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, e.getMessage());
        }
    }

    private static List<GrantedAuthority> papeis(FirebaseToken token) {
        if (Boolean.TRUE.equals(token.getClaims().get(CLAIM_ADMIN))) {
            return List.of(new SimpleGrantedAuthority(PAPEL_ADMIN));
        }
        return List.of();
    }
}
