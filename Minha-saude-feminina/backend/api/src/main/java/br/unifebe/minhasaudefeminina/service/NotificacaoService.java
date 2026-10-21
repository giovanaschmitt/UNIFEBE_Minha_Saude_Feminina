package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.dao.CicloMenstrualDao;
import br.unifebe.minhasaudefeminina.dao.DispositivoNotificacaoDao;
import br.unifebe.minhasaudefeminina.dto.DispositivoRequest;
import br.unifebe.minhasaudefeminina.exception.RequisicaoInvalidaException;
import br.unifebe.minhasaudefeminina.model.DispositivoNotificacao;
import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.MessagingErrorCode;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.SendResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class NotificacaoService {

    private static final Logger log = LoggerFactory.getLogger(NotificacaoService.class);
    private static final ZoneId FUSO = ZoneId.of("America/Sao_Paulo");
    private static final Set<MessagingErrorCode> TOKEN_INVALIDO =
            Set.of(MessagingErrorCode.UNREGISTERED, MessagingErrorCode.INVALID_ARGUMENT);

    private final DispositivoNotificacaoDao dispositivoDao;
    private final CicloMenstrualDao cicloDao;

    @Value("${app.notificacoes.ativo:true}")
    private boolean ativo;

    public NotificacaoService(DispositivoNotificacaoDao dispositivoDao, CicloMenstrualDao cicloDao) {
        this.dispositivoDao = dispositivoDao;
        this.cicloDao = cicloDao;
    }

    /** Vincula o token do aparelho à usuária (um token pertence a uma conta por vez). */
    @Transactional
    public void registrar(String uid, DispositivoRequest dados) {
        DispositivoNotificacao dispositivo = dispositivoDao.findByToken(dados.token())
                .orElseGet(() -> new DispositivoNotificacao(dados.token()));
        dispositivo.setUidUsuaria(uid);
        dispositivo.setPlataforma(dados.plataforma());
        if (dados.lembreteCiclo() != null) {
            dispositivo.setLembreteCiclo(dados.lembreteCiclo());
        }
        dispositivoDao.save(dispositivo);
    }

    @Transactional
    public void remover(String uid, String token) {
        dispositivoDao.findByTokenAndUidUsuaria(token, uid).ifPresent(dispositivoDao::delete);
    }

    /** Envia uma notificação de teste para os aparelhos da usuária; devolve quantos receberam. */
    @Transactional
    public int enviarTeste(String uid) {
        List<String> tokens = dispositivoDao.findAllByUidUsuaria(uid).stream()
                .map(DispositivoNotificacao::getToken)
                .toList();
        if (tokens.isEmpty()) {
            throw new RequisicaoInvalidaException("Nenhum aparelho registrado para notificações.");
        }
        return enviar(tokens, "Notificações ativadas 💗", "Você vai receber os lembretes do seu ciclo por aqui.");
    }

    /** Todo dia (09:00 por padrão) avisa quem tem menstruação prevista para daqui a 2 dias ou para hoje. */
    @Scheduled(cron = "${app.notificacoes.cron:0 0 9 * * *}", zone = "America/Sao_Paulo")
    @Transactional
    public void enviarLembretesDeCiclo() {
        if (!ativo) {
            return;
        }
        Map<String, List<String>> tokensPorUsuaria = dispositivoDao.findAllByLembreteCicloTrue().stream()
                .collect(Collectors.groupingBy(DispositivoNotificacao::getUidUsuaria,
                        Collectors.mapping(DispositivoNotificacao::getToken, Collectors.toList())));

        LocalDate hoje = LocalDate.now(FUSO);
        int enviados = 0;
        for (var entrada : tokensPorUsuaria.entrySet()) {
            var previsao = PrevisaoCiclo.proximoInicio(cicloDao.findAllByUidUsuariaOrderByDataInicioDesc(entrada.getKey()));
            if (previsao.isEmpty()) {
                continue;
            }
            long faltam = ChronoUnit.DAYS.between(hoje, previsao.get());
            if (faltam == 2) {
                enviados += enviar(entrada.getValue(), "Seu ciclo está chegando",
                        "Sua menstruação deve começar em 2 dias. Que tal deixar tudo preparado?");
            } else if (faltam == 0) {
                enviados += enviar(entrada.getValue(), "Menstruação prevista para hoje",
                        "Quando ela começar, registre no app para melhorar suas previsões.");
            }
        }
        log.info("Lembretes de ciclo enviados: {} notificação(ões).", enviados);
    }

    private int enviar(List<String> tokens, String titulo, String corpo) {
        MulticastMessage mensagem = MulticastMessage.builder()
                .addAllTokens(tokens)
                .setNotification(Notification.builder().setTitle(titulo).setBody(corpo).build())
                .build();
        try {
            BatchResponse resposta = FirebaseMessaging.getInstance().sendEachForMulticast(mensagem);
            descartarTokensInvalidos(tokens, resposta.getResponses());
            return resposta.getSuccessCount();
        } catch (FirebaseMessagingException e) {
            log.warn("Falha ao enviar notificação: {}", e.getMessage());
            return 0;
        }
    }

    private void descartarTokensInvalidos(List<String> tokens, List<SendResponse> respostas) {
        List<String> invalidos = new ArrayList<>();
        for (int i = 0; i < respostas.size(); i++) {
            SendResponse resposta = respostas.get(i);
            if (!resposta.isSuccessful() && resposta.getException() != null
                    && TOKEN_INVALIDO.contains(resposta.getException().getMessagingErrorCode())) {
                invalidos.add(tokens.get(i));
            }
        }
        if (!invalidos.isEmpty()) {
            dispositivoDao.deleteAllByTokenIn(invalidos);
        }
    }
}
