package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.dao.CicloMenstrualDao;
import br.unifebe.minhasaudefeminina.dto.CicloRequest;
import br.unifebe.minhasaudefeminina.dto.CicloResponse;
import br.unifebe.minhasaudefeminina.exception.ConflitoException;
import br.unifebe.minhasaudefeminina.exception.RecursoNaoEncontradoException;
import br.unifebe.minhasaudefeminina.exception.RequisicaoInvalidaException;
import br.unifebe.minhasaudefeminina.model.CicloMenstrual;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CicloService {

    private final CicloMenstrualDao cicloDao;

    public CicloService(CicloMenstrualDao cicloDao) {
        this.cicloDao = cicloDao;
    }

    @Transactional(readOnly = true)
    public List<CicloResponse> listar(String uid) {
        return cicloDao.findAllByUidUsuariaOrderByDataInicioDesc(uid).stream()
                .map(CicloResponse::de)
                .toList();
    }

    @Transactional
    public CicloResponse criar(String uid, CicloRequest dados) {
        if (cicloDao.existsByUidUsuariaAndDataInicio(uid, dados.dataInicio())) {
            throw new ConflitoException("Já existe um ciclo começando nesta data.");
        }
        CicloMenstrual ciclo = new CicloMenstrual(uid);
        aplicar(ciclo, dados);
        return CicloResponse.de(cicloDao.save(ciclo));
    }

    @Transactional
    public CicloResponse atualizar(String uid, Long id, CicloRequest dados) {
        CicloMenstrual ciclo = buscar(uid, id);
        if (cicloDao.existsByUidUsuariaAndDataInicioAndIdNot(uid, dados.dataInicio(), id)) {
            throw new ConflitoException("Já existe um ciclo começando nesta data.");
        }
        aplicar(ciclo, dados);
        return CicloResponse.de(cicloDao.save(ciclo));
    }

    @Transactional
    public void excluir(String uid, Long id) {
        cicloDao.delete(buscar(uid, id));
    }

    private CicloMenstrual buscar(String uid, Long id) {
        return cicloDao.findByIdAndUidUsuaria(id, uid)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Ciclo não encontrado."));
    }

    private static void aplicar(CicloMenstrual ciclo, CicloRequest dados) {
        if (dados.dataFim() != null && dados.dataFim().isBefore(dados.dataInicio())) {
            throw new RequisicaoInvalidaException("A data de término não pode ser anterior ao início.");
        }
        ciclo.setDataInicio(dados.dataInicio());
        ciclo.setDataFim(dados.dataFim());
        ciclo.setFluxo(dados.fluxo() == null || dados.fluxo().isBlank() ? null : dados.fluxo().toLowerCase());
        ciclo.setObservacao(dados.observacao() == null || dados.observacao().isBlank() ? null : dados.observacao().trim());
    }
}
