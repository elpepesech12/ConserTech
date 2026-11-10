package com.consertech.auth.controller;

import com.consertech.auth.models.Departamento;
import com.consertech.auth.models.Residente;
import com.consertech.auth.repositories.DepartamentoRepository;
import com.consertech.auth.repositories.ResidenteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/departamentos")
@CrossOrigin(origins = "*")
public class DepartamentoController {

    @Autowired
    private DepartamentoRepository departamentoRepository;

    @Autowired
    private ResidenteRepository residenteRepository;

    @GetMapping
    public List<Departamento> listarTodos() {
        return departamentoRepository.findByActivoTrueOrderByNumeroAsc();
    }

    @PostMapping
    public Departamento crear(@RequestBody Departamento depto) {
        return departamentoRepository.save(depto);
    }

    @GetMapping("/{id}/residentes")
    public List<Residente> obtenerResidentesPorDepto(@PathVariable Long id) {
        return residenteRepository.findByDepartamentoId(id);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> darDeBaja(@PathVariable Long id) {
        return departamentoRepository.findById(id).map(d -> {
            d.setActivo(false);
            departamentoRepository.save(d);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
