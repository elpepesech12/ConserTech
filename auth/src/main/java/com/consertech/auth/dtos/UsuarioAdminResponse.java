package com.consertech.auth.dtos;

import com.consertech.auth.models.Rol;
import com.consertech.auth.models.Usuario;

import java.time.LocalDateTime;

public class UsuarioAdminResponse {

    private Long id;
    private String email;
    private String nombre;
    private String telefono;
    private Rol rol;
    private Boolean activo;
    private LocalDateTime creadoEn;

    public UsuarioAdminResponse() {
    }

    public UsuarioAdminResponse(
            Long id,
            String email,
            String nombre,
            String telefono,
            Rol rol,
            Boolean activo,
            LocalDateTime creadoEn) {
        this.id = id;
        this.email = email;
        this.nombre = nombre;
        this.telefono = telefono;
        this.rol = rol;
        this.activo = activo;
        this.creadoEn = creadoEn;
    }

    public static UsuarioAdminResponse desdeUsuario(Usuario usuario) {
        return new UsuarioAdminResponse(
                usuario.getId(),
                usuario.getEmail(),
                usuario.getNombre(),
                usuario.getTelefono(),
                usuario.getRol(),
                usuario.getActivo(),
                usuario.getCreadoEn());
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getNombre() {
        return nombre;
    }

    public String getTelefono() {
        return telefono;
    }

    public Rol getRol() {
        return rol;
    }

    public Boolean getActivo() {
        return activo;
    }

    public LocalDateTime getCreadoEn() {
        return creadoEn;
    }
}
