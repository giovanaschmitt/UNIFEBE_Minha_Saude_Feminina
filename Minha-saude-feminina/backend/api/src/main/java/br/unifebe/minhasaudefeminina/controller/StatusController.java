package br.unifebe.minhasaudefeminina.controller;

import br.unifebe.minhasaudefeminina.model.SystemStatus;
import br.unifebe.minhasaudefeminina.service.SystemStatusService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/status")
public class StatusController {

    private final SystemStatusService statusService;

    public StatusController(SystemStatusService statusService) {
        this.statusService = statusService;
    }

    @GetMapping
    public SystemStatus getStatus() {
        return statusService.getCurrentStatus();
    }
}