package com.consertech.auth.models;

import jakarta.persistence.*;

@Entity
@Table(name = "estacionamientos")
public class Estacionamiento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 20)
    private String codigo;

    @Column(length = 20)
    private String tipo = "VISITA"; // VISITA, RESIDENTE

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private EstadoEstacionamiento estado = EstadoEstacionamiento.DISPONIBLE;

    private String observacion;

    public Estacionamiento() {
    }

    public Estacionamiento(String codigo, String tipo, EstadoEstacionamiento estado) {
        this.codigo = codigo;
        this.tipo = tipo;
        this.estado = estado;
    }

    public Long getId() {
        return id;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public EstadoEstacionamiento getEstado() {
        return estado;
    }

    public void setEstado(EstadoEstacionamiento estado) {
        this.estado = estado;
    }

    public String getObservacion() {
        return observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }
}