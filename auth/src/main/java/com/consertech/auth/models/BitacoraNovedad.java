package com.consertech.auth.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "bitacora_novedades")
public class BitacoraNovedad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "conserje_nombre", nullable = false, length = 150)
    private String conserjeNombre;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private TurnoConserje turno;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private CategoriaNovedad categoria;

    @Column(nullable = false, length = 150)
    private String titulo;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "fecha_registro", nullable = false)
    private LocalDateTime fechaRegistro = LocalDateTime.now();

    public BitacoraNovedad() {
    }

    public Long getId() {
        return id;
    }

    public String getConserjeNombre() {
        return conserjeNombre;
    }

    public void setConserjeNombre(String conserjeNombre) {
        this.conserjeNombre = conserjeNombre;
    }

    public TurnoConserje getTurno() {
        return turno;
    }

    public void setTurno(TurnoConserje turno) {
        this.turno = turno;
    }

    public CategoriaNovedad getCategoria() {
        return categoria;
    }

    public void setCategoria(CategoriaNovedad categoria) {
        this.categoria = categoria;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }
}