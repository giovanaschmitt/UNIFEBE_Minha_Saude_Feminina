package com.complexo.UNIFEBE_Complexo_Esportivo.service;

import com.complexo.UNIFEBE_Complexo_Esportivo.dao.Ambientes;
import com.complexo.UNIFEBE_Complexo_Esportivo.dao.AmbientesDAOImpl;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class AmbientesService {

    private final AmbientesDAOImpl dao = new AmbientesDAOImpl();

    public int inserir(Ambientes a) {
        return dao.inserirAmbiente(a);
    }

    public int remover(int id) {
        Ambientes a = new Ambientes();
        a.setId_AMBIENTES(id);
        return dao.removerAmbiente(a);
    }

    public int atualizar(Ambientes a) {
        return dao.atualizarAmbiente(a);
    }

    public ArrayList<Ambientes> listar() {
        return dao.consultarAmbientes();
    }

    public ArrayList<Ambientes> buscarPorNome(String nome) {
        return dao.buscarAmbientePorNome(nome);
    }
}
