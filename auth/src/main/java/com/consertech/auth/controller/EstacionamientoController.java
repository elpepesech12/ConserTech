package com.consertech.auth.controller;

import com.consertech.auth.models.Estacionamiento;
import com.consertech.auth.models.EstadoEstacionamiento;
import com.consertech.auth.repositories.EstacionamientoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/estacionamientos")
@CrossOrigin(origins = "*")
public class EstacionamientoController {

    @Autowired
    private EstacionamientoRepository estacionamientoRepository;

    @GetMapping
    public List<Estacionamiento> listar() {
        return estacionamientoRepository.findAll();
    }

    @GetMapping("/disponibles")
    public List<Estacionamiento> listarDisponibles() {
        return estacionamientoRepository.findByEstado(EstadoEstacionamiento.DISPONIBLE);
    }

    @GetMapping("/metricas")
    public Map<String, Long> obtenerMetricas() {
        Map<String, Long> metricas = new HashMap<>();
        metricas.put("total", estacionamientoRepository.count());
        metricas.put("disponibles", estacionamientoRepository.countByEstado(EstadoEstacionamiento.DISPONIBLE));
        metricas.put("ocupados", estacionamientoRepository.countByEstado(EstadoEstacionamiento.OCUPADO));
        metricas.put("mantencion", estacionamientoRepository.countByEstado(EstadoEstacionamiento.MANTENCION));
        return metricas;
    }

    @PutMapping("/{id}/estado")
    public ResponseEntity<Estacionamiento> cambiarEstado(
            @PathVariable Long id,
            @RequestParam EstadoEstacionamiento nuevoEstado) {
        return estacionamientoRepository.findById(id).map(e -> {
            e.setEstado(nuevoEstado);
            return ResponseEntity.ok(estacionamientoRepository.save(e));
        }).orElse(ResponseEntity.notFound().build());
    }
}