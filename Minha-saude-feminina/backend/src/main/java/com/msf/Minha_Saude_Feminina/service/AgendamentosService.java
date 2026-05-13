package com.complexo.UNIFEBE_Complexo_Esportivo.service;

import com.complexo.UNIFEBE_Complexo_Esportivo.dao.Agendamentos;
import com.complexo.UNIFEBE_Complexo_Esportivo.dao.AgendamentosDAOImpl;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class AgendamentosService {

    private final AgendamentosDAOImpl dao = new AgendamentosDAOImpl();

    public int inserirAgendamento(Agendamentos a) {
        return dao.inserirAgendamento(a);
    }

    public int cancelarAgendamento(int id) {
        Agendamentos a = new Agendamentos();
        a.setID_AGENDAMENTOS(id);
        return dao.cancelarAgendamento(a);
    }

    public ArrayList<Agendamentos> consultarAgendamentosUsuario(int id) {
        return dao.consultarAgendamentosUsuario(id);
    }

    public ArrayList<Agendamentos> consultarAgendamentosUsuarioFuturos(int id) {
        return dao.consultarAgendamentosUsuarioFuturos(id);
    }

    public ArrayList<Agendamentos> consultarAgendamentosAmbiente(int id) {
        return dao.consultarAgendamentosAmbiente(id);
    }

    public ArrayList<Agendamentos> consultarAgendamentosAmbienteFuturos(int id) {
        return dao.consultarAgendamentosAmbienteFuturos(id);
    }
}
