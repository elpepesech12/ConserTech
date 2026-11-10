package com.consertech.auth.controller;

import com.consertech.auth.models.Encomienda;
import com.consertech.auth.models.EstadoEncomienda;
import com.consertech.auth.repositories.EncomiendaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/encomiendas")
@CrossOrigin(origins = "*")
public class EncomiendaController {

    @Autowired
    private EncomiendaRepository encomiendaRepository;

    @GetMapping
    public ResponseEntity<List<Encomienda>> listarTodas() {
        try {
            List<Encomienda> lista = encomiendaRepository.findAll();
            return ResponseEntity.ok(lista != null ? lista : Collections.emptyList());
        } catch (Exception e) {
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    @GetMapping("/pendientes")
    public ResponseEntity<List<Encomienda>> listarPendientes() {
        try {
            List<Encomienda> lista = encomiendaRepository
                    .findByEstadoOrderByFechaRecepcionDesc(EstadoEncomienda.EN_CONSERJERIA);
            return ResponseEntity.ok(lista != null ? lista : Collections.emptyList());
        } catch (Exception e) {
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    @GetMapping("/depto/{numeroDepto}")
    public ResponseEntity<List<Encomienda>> listarPorDepto(@PathVariable String numeroDepto) {
        try {
            List<Encomienda> lista = encomiendaRepository.findByDeptoDestinoOrderByFechaRecepcionDesc(numeroDepto);
            return ResponseEntity.ok(lista != null ? lista : Collections.emptyList());
        } catch (Exception e) {
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    @PostMapping("/recepcion")
    public ResponseEntity<?> registrarRecepcion(@RequestBody Encomienda encomienda) {
        try {
            encomienda.setFechaRecepcion(LocalDateTime.now());
            encomienda.setEstado(EstadoEncomienda.EN_CONSERJERIA);
            if (encomienda.getCourier() == null || encomienda.getCourier().isEmpty()) {
                encomienda.setCourier("Chilexpress");
            }
            Encomienda guardada = encomiendaRepository.save(encomienda);
            return ResponseEntity.ok(guardada);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error al registrar encomienda: " + e.getMessage());
        }
    }

    @PutMapping("/{id}/entregar")
    public ResponseEntity<?> registrarEntrega(
            @PathVariable Long id,
            @RequestParam(required = false, defaultValue = "Residente") String retiradoPor,
            @RequestParam(required = false, defaultValue = "Presencial") String rutRetiro) {
        try {
            return encomiendaRepository.findById(id).map(e -> {
                e.setEstado(EstadoEncomienda.ENTREGADO);
                e.setFechaEntrega(LocalDateTime.now());
                e.setRetiradoPor(retiradoPor);
                e.setRutRetiro(rutRetiro);
                return ResponseEntity.ok(encomiendaRepository.save(e));
            }).orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error al entregar: " + e.getMessage());
        }
    }

    @GetMapping("/metricas")
    public ResponseEntity<Map<String, Long>> obtenerMetricas() {
        Map<String, Long> metricas = new HashMap<>();
        try {
            metricas.put("total", encomiendaRepository.count());
            metricas.put("pendientes", encomiendaRepository.countByEstado(EstadoEncomienda.EN_CONSERJERIA));
            metricas.put("entregadas", encomiendaRepository.countByEstado(EstadoEncomienda.ENTREGADO));
        } catch (Exception e) {
            metricas.put("total", 0L);
            metricas.put("pendientes", 0L);
            metricas.put("entregadas", 0L);
        }
        return ResponseEntity.ok(metricas);
    }
}