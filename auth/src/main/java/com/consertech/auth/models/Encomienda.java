package com.consertech.auth.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "encomiendas")
public class Encomienda {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50)
    private String deptoDestino;

    @Column(nullable = false, length = 80)
    private String courier;

    @Column(name = "codigo_seguimiento", length = 100)
    private String codigoSeguimiento;

    @Column(name = "destinatario_nombre", nullable = false, length = 150)
    private String destinatarioNombre;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private EstadoEncomienda estado = EstadoEncomienda.EN_CONSERJERIA;

    @Column(name = "fecha_recepcion", nullable = false)
    private LocalDateTime fechaRecepcion = LocalDateTime.now();

    @Column(name = "fecha_entrega")
    private LocalDateTime fechaEntrega;

    @Column(name = "retirado_por", length = 150)
    private String retiradoPor;

    @Column(name = "rut_retiro", length = 20)
    private String rutRetiro;

    private String observacion;

    public Encomienda() {
    }

    public Long getId() {
        return id;
    }

    public String getDeptoDestino() {
        return deptoDestino;
    }

    public void setDeptoDestino(String deptoDestino) {
        this.deptoDestino = deptoDestino;
    }

    public String getCourier() {
        return courier;
    }

    public void setCourier(String courier) {
        this.courier = courier;
    }

    public String getCodigoSeguimiento() {
        return codigoSeguimiento;
    }

    public void setCodigoSeguimiento(String codigoSeguimiento) {
        this.codigoSeguimiento = codigoSeguimiento;
    }

    public String getDestinatarioNombre() {
        return destinatarioNombre;
    }

    public void setDestinatarioNombre(String destinatarioNombre) {
        this.destinatarioNombre = destinatarioNombre;
    }

    public EstadoEncomienda getEstado() {
        return estado;
    }

    public void setEstado(EstadoEncomienda estado) {
        this.estado = estado;
    }

    public LocalDateTime getFechaRecepcion() {
        return fechaRecepcion;
    }

    public void setFechaRecepcion(LocalDateTime fechaRecepcion) {
        this.fechaRecepcion = fechaRecepcion;
    }

    public LocalDateTime getFechaEntrega() {
        return fechaEntrega;
    }

    public void setFechaEntrega(LocalDateTime fechaEntrega) {
        this.fechaEntrega = fechaEntrega;
    }

    public String getRetiradoPor() {
        return retiradoPor;
    }

    public void setRetiradoPor(String retiradoPor) {
        this.retiradoPor = retiradoPor;
    }

    public String getRutRetiro() {
        return rutRetiro;
    }

    public void setRutRetiro(String rutRetiro) {
        this.rutRetiro = rutRetiro;
    }

    public String getObservacion() {
        return observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }
}