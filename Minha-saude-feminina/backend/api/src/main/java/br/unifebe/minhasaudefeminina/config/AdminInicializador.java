package br.unifebe.minhasaudefeminina.config;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;

import br.unifebe.minhasaudefeminina.security.FirebaseTokenFilter;

/**
 * Concede o papel de administradora (custom claim "admin" no Firebase) às contas
 * listadas em app.admin.emails. A conta precisa já existir no Firebase Authentication;
 * a pessoa deve sair e entrar de novo no painel para o token trazer o papel.
 */
@Component
public class AdminInicializador {

    private static final Logger log = LoggerFactory.getLogger(AdminInicializador.class);

    @Value("${app.admin.emails:}")
    private String emails;

    @EventListener(ApplicationReadyEvent.class)
    public void concederPapeis() {
        Arrays.stream(emails.split(","))
                .map(String::trim)
                .filter(email -> !email.isEmpty())
                .forEach(this::concederPapel);
    }

    private void concederPapel(String email) {
        try {
            FirebaseAuth auth = FirebaseAuth.getInstance();
            UserRecord usuario = auth.getUserByEmail(email);
            if (Boolean.TRUE.equals(usuario.getCustomClaims().get(FirebaseTokenFilter.CLAIM_ADMIN))) {
                return;
            }
            Map<String, Object> claims = new HashMap<>(usuario.getCustomClaims());
            claims.put(FirebaseTokenFilter.CLAIM_ADMIN, true);
            auth.setCustomUserClaims(usuario.getUid(), claims);
            log.info("Papel de administradora concedido a {}.", email);
        } catch (FirebaseAuthException e) {
            log.warn("Não foi possível conceder o papel de administradora a {}: {}", email, e.getMessage());
        }
    }
}
