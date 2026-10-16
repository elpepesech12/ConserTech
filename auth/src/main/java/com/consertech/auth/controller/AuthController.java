package com.consertech.auth.controller;

import com.consertech.auth.dtos.AuthResponse;
import com.consertech.auth.dtos.LoginRequest;
import com.consertech.auth.models.Rol;
import com.consertech.auth.models.Usuario;
import com.consertech.auth.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        Optional<Usuario> userOpt = usuarioRepository.findByEmail(request.getEmail());

        if (userOpt.isEmpty()) {
            Rol rolAsignado = Usuario.resolverRolPorEmail(request.getEmail());
            String nombreDefault = request.getEmail().contains("@") 
                    ? request.getEmail().split("@")[0] 
                    : request.getEmail();

            Usuario nuevo = new Usuario(
                    request.getEmail(),
                    passwordEncoder.encode(request.getPassword()),
                    nombreDefault,
                    rolAsignado
            );
            usuarioRepository.save(nuevo);
            userOpt = Optional.of(nuevo);
        }

        Usuario user = userOpt.get();
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return ResponseEntity.status(401).body("Credenciales inválidas");
        }

        AuthResponse response = new AuthResponse(
                "dummy-jwt-token-" + user.getEmail(),
                user.getEmail(),
                user.getNombre(),
                user.getRol().name()
        );

        return ResponseEntity.ok(response);
    }
}