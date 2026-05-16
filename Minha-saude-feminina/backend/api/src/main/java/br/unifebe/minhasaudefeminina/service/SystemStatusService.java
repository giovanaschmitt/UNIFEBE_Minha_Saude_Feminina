package br.unifebe.minhasaudefeminina.service;

import br.unifebe.minhasaudefeminina.dao.SystemStatusDAO;
import br.unifebe.minhasaudefeminina.model.SystemStatus;
import org.springframework.stereotype.Service;

@Service
public class SystemStatusService {

    private final SystemStatusDAO statusDAO;

    public SystemStatusService(SystemStatusDAO statusDAO) {
        this.statusDAO = statusDAO;
    }

    public SystemStatus getCurrentStatus() {
        return statusDAO.getCurrentStatus();
    }
}