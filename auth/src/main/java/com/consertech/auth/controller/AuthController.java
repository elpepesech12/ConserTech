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
        if (request == null || request.getEmail() == null || request.getPassword() == null) {
            return ResponseEntity.badRequest().body("Email y contraseña son obligatorios");
        }

        String email = request.getEmail().trim().toLowerCase();
        String password = request.getPassword().trim();

        Optional<Usuario> userOpt = usuarioRepository.findByEmail(email);
        Usuario user;

        if (userOpt.isEmpty()) {
            // Si el usuario no existe en la base de datos, se crea automáticamente
            Rol rolAsignado = Usuario.resolverRolPorEmail(email);
            String nombreDefault = email.contains("@") ? email.split("@")[0] : email;

            user = new Usuario(
                    email,
                    passwordEncoder.encode(password),
                    nombreDefault,
                    rolAsignado);
            user.setActivo(true);
            usuarioRepository.save(user);
        } else {
            user = userOpt.get();

            // Asegura que rol y activo no queden nulos por migraciones de tablas
            if (user.getRol() == null) {
                user.setRol(Usuario.resolverRolPorEmail(user.getEmail()));
            }
            if (user.getActivo() == null) {
                user.setActivo(true);
            }

            // Si es la cuenta administrador por defecto y la contraseña almacenada difiere,
            // se actualiza
            if (email.equals("admin@admin.com") && password.equals("admin123")) {
                user.setPassword(passwordEncoder.encode("admin123"));
                user.setRol(Rol.ROLE_ADMIN);
                usuarioRepository.save(user);
            } else if (!passwordEncoder.matches(password, user.getPassword())) {
                return ResponseEntity.status(401).body("Credenciales inválidas");
            } else {
                usuarioRepository.save(user);
            }
        }

        String rolNombre = (user.getRol() != null) ? user.getRol().name() : "ROLE_ADMIN";
        String nombreUsuario = (user.getNombre() != null) ? user.getNombre() : "Usuario";

        AuthResponse response = new AuthResponse(
                "token-" + user.getEmail(),
                user.getEmail(),
                nombreUsuario,
                rolNombre);

        return ResponseEntity.ok(response);
    }
}