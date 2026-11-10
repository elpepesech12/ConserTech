package com.consertech.auth.controller;

import com.consertech.auth.models.EstadoEstacionamiento;
import com.consertech.auth.models.Visita;
import com.consertech.auth.repositories.EstacionamientoRepository;
import com.consertech.auth.repositories.VisitaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/visitas")
@CrossOrigin(origins = "*")
public class VisitaController {

    @Autowired
    private VisitaRepository visitaRepository;

    @Autowired
    private EstacionamientoRepository estacionamientoRepository;

    @GetMapping
    public ResponseEntity<List<Visita>> obtenerVisitas() {
        try {
            List<Visita> lista = visitaRepository.findAllByOrderByHoraIngresoDesc();
            return ResponseEntity.ok(lista != null ? lista : Collections.emptyList());
        } catch (Exception e) {
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    @PostMapping("/ingreso")
    public ResponseEntity<?> registrarIngreso(@RequestBody Visita visita) {
        try {
            if (visita.getHoraIngreso() == null) {
                visita.setHoraIngreso(LocalDateTime.now());
            }
            if (visita.getTipoDocumento() == null) {
                visita.setTipoDocumento("RUT");
            }

            // Si incluye estacionamiento, actualizarlo a OCUPADO
            if (visita.getEstacionamiento() != null && visita.getEstacionamiento().getId() != null) {
                estacionamientoRepository.findById(visita.getEstacionamiento().getId()).ifPresent(e -> {
                    e.setEstado(EstadoEstacionamiento.OCUPADO);
                    estacionamientoRepository.save(e);
                });
            }

            Visita guardada = visitaRepository.save(visita);
            return ResponseEntity.ok(guardada);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error al registrar visita: " + e.getMessage());
        }
    }

    @PutMapping("/{id}/salida")
    public ResponseEntity<?> registrarSalida(@PathVariable Long id) {
        try {
            Optional<Visita> visitaOpt = visitaRepository.findById(id);
            if (visitaOpt.isPresent()) {
                Visita v = visitaOpt.get();
                v.setHoraSalida(LocalDateTime.now());

                // Liberar estacionamiento si tenía uno
                if (v.getEstacionamiento() != null) {
                    v.getEstacionamiento().setEstado(EstadoEstacionamiento.DISPONIBLE);
                    estacionamientoRepository.save(v.getEstacionamiento());
                }

                visitaRepository.save(v);
                return ResponseEntity.ok(v);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error al marcar salida: " + e.getMessage());
        }
    }
}