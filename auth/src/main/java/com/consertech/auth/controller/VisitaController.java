package com.consertech.auth.controller;

import com.consertech.auth.models.Visita;
import com.consertech.auth.repositories.VisitaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/visitas")
@CrossOrigin(origins = "*")
public class VisitaController {

    @Autowired
    private VisitaRepository visitaRepository;

    @GetMapping
    public List<Visita> obtenerVisitas() {
        return visitaRepository.findAllByOrderByHoraIngresoDesc();
    }

    @PostMapping("/ingreso")
    public Visita registrarIngreso(@RequestBody Visita visita) {
        visita.setHoraIngreso(LocalDateTime.now());
        return visitaRepository.save(visita);
    }

    @PutMapping("/{id}/salida")
    public ResponseEntity<?> registrarSalida(@PathVariable Long id) {
        Optional<Visita> visitaOpt = visitaRepository.findById(id);
        if (visitaOpt.isPresent()) {
            Visita v = visitaOpt.get();
            v.setHoraSalida(LocalDateTime.now());
            visitaRepository.save(v);
            return ResponseEntity.ok(v);
        }
        return ResponseEntity.notFound().build();
    }
}