package com.consertech.auth.controller;

import com.consertech.auth.models.BitacoraNovedad;
import com.consertech.auth.repositories.BitacoraRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/bitacora")
@CrossOrigin(origins = "*")
public class BitacoraController {

    @Autowired
    private BitacoraRepository bitacoraRepository;

    @GetMapping
    public List<BitacoraNovedad> listarNovedades() {
        return bitacoraRepository.findAllByOrderByFechaRegistroDesc();
    }

    @PostMapping
    public BitacoraNovedad registrarNovedad(@RequestBody BitacoraNovedad novedad) {
        novedad.setFechaRegistro(LocalDateTime.now());
        return bitacoraRepository.save(novedad);
    }
}