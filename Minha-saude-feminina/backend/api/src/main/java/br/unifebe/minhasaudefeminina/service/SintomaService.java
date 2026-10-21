package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.dao.RegistroSintomaDao;
import br.unifebe.minhasaudefeminina.dao.SintomaDao;
import br.unifebe.minhasaudefeminina.dto.SintomaCatalogoResponse;
import br.unifebe.minhasaudefeminina.dto.SintomaRequest;
import br.unifebe.minhasaudefeminina.dto.SintomaResponse;
import br.unifebe.minhasaudefeminina.exception.RecursoNaoEncontradoException;
import br.unifebe.minhasaudefeminina.exception.RequisicaoInvalidaException;
import br.unifebe.minhasaudefeminina.model.RegistroSintoma;
import br.unifebe.minhasaudefeminina.model.Sintoma;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class SintomaService {

    private final SintomaDao sintomaDao;
    private final RegistroSintomaDao registroSintomaDao;

    public SintomaService(SintomaDao sintomaDao, RegistroSintomaDao registroSintomaDao) {
        this.sintomaDao = sintomaDao;
        this.registroSintomaDao = registroSintomaDao;
    }

    @Transactional(readOnly = true)
    public List<SintomaCatalogoResponse> catalogo() {
        return sintomaDao.findAllByAtivoTrueOrderByOrdem().stream()
                .map(SintomaCatalogoResponse::de)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<SintomaResponse> listar(String uid) {
        return registroSintomaDao.findAllByUidUsuariaOrderByDataRegistroDescCriadoEmDesc(uid).stream()
                .map(SintomaResponse::de)
                .toList();
    }

    /** Registra o sintoma no dia; se o mesmo sintoma já foi registrado no dia, atualiza o registro. */
    @Transactional
    public SintomaResponse registrar(String uid, SintomaRequest dados) {
        String nome = dados.sintoma().trim();
        Sintoma sintoma = sintomaDao.findByNomeIgnoreCaseAndAtivoTrue(nome)
                .orElseThrow(() -> new RequisicaoInvalidaException("Sintoma não cadastrado: " + nome + "."));
        LocalDate dia = dados.dataRegistro() == null ? LocalDate.now() : dados.dataRegistro();

        RegistroSintoma registro = registroSintomaDao
                .findByUidUsuariaAndSintomaIdAndDataRegistro(uid, sintoma.getId(), dia)
                .orElseGet(() -> new RegistroSintoma(uid, sintoma, dia));
        registro.setIntensidade(dados.intensidade().toLowerCase());
        registro.setObservacao(dados.observacao());
        return SintomaResponse.de(registroSintomaDao.save(registro));
    }

    @Transactional
    public void excluir(String uid, Long id) {
        RegistroSintoma registro = registroSintomaDao.findByIdAndUidUsuaria(id, uid)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Registro de sintoma não encontrado."));
        registroSintomaDao.delete(registro);
    }
}
