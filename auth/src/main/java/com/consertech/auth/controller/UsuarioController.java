package com.consertech.auth.controller;

import com.consertech.auth.dtos.UsuarioAdminResponse;
import com.consertech.auth.models.Usuario;
import com.consertech.auth.repositories.UsuarioRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;

    public UsuarioController(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    @GetMapping
    public List<UsuarioAdminResponse> listarUsuarios() {
        return usuarioRepository.findAll()
                .stream()
                .map(UsuarioAdminResponse::desdeUsuario)
                .collect(Collectors.toList());
    }

    @PutMapping("/{id}/estado")
    public ResponseEntity<UsuarioAdminResponse> cambiarEstado(
            @PathVariable Long id,
            @RequestParam Boolean activo) {

        return usuarioRepository.findById(id)
                .map(usuario -> {
                    usuario.setActivo(activo);
                    Usuario actualizado = usuarioRepository.save(usuario);
                    return ResponseEntity.ok(
                            UsuarioAdminResponse.desdeUsuario(actualizado));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
