package com.consertech.auth.controller;

import com.consertech.auth.models.Residente;
import com.consertech.auth.repositories.ResidenteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/residentes")
@CrossOrigin(origins = "*")
public class ResidenteController {

    @Autowired
    private ResidenteRepository residenteRepository;

    @GetMapping
    public List<Residente> listar() {
        return residenteRepository.findAll();
    }

    @GetMapping("/buscar")
    public List<Residente> buscarPorNombre(@RequestParam String query) {
        return residenteRepository.findByNombreContainingIgnoreCaseOrApellidoContainingIgnoreCase(query, query);
    }

    @GetMapping("/rut/{rut}")
    public ResponseEntity<Residente> buscarPorRut(@PathVariable String rut) {
        return residenteRepository.findByRut(rut)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Residente registrar(@RequestBody Residente residente) {
        return residenteRepository.save(residente);
    }
}