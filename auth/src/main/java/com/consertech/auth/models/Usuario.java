package com.consertech.auth.models;

import jakarta.persistence.*;

@Entity
@Table(name = "usuarios")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    private String nombre;

    @Enumerated(EnumType.STRING)
    private Rol rol;

    public Usuario() {
    }

    public Usuario(String email, String password, String nombre, Rol rol) {
        this.email = email;
        this.password = password;
        this.nombre = nombre;
        this.rol = rol;
    }

    public static Rol resolverRolPorEmail(String email) {
        if (email == null) return Rol.ROLE_RESIDENTE;
        String emailLower = email.toLowerCase().trim();
        if (emailLower.endsWith("@admin.com") || emailLower.contains("admin@")) {
            return Rol.ROLE_ADMIN;
        } else if (emailLower.endsWith("@conserje.com") || emailLower.contains("conserje@")) {
            return Rol.ROLE_CONSERJE;
        }
        return Rol.ROLE_RESIDENTE;
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Rol getRol() {
        return rol;
    }

    public void setRol(Rol rol) {
        this.rol = rol;
    }
}