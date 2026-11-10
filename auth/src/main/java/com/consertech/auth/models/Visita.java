package com.consertech.auth.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "visitas")
public class Visita {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String nombreCompleto;

    @Column(nullable = false, length = 30)
    private String tipoDocumento = "RUT";

    @Column(nullable = false, length = 30)
    private String numeroDocumento;

    @Column(nullable = false, length = 50)
    private String deptoDestino;

    private String residenteQueAutoriza;

    @Column(length = 20)
    private String patenteVehiculo;

    @Column(name = "metodo_ingreso", length = 20)
    private String metodoIngreso = "MANUAL"; // MANUAL o QR_CEDULA

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "estacionamiento_id")
    private Estacionamiento estacionamiento;

    @Column(nullable = false)
    private LocalDateTime horaIngreso = LocalDateTime.now();

    private LocalDateTime horaSalida;

    private String observaciones;

    public Visita() {
    }

    public Visita(String nombreCompleto, String tipoDocumento, String numeroDocumento,
            String deptoDestino, String residenteQueAutoriza) {
        this.nombreCompleto = nombreCompleto;
        this.tipoDocumento = tipoDocumento;
        this.numeroDocumento = numeroDocumento;
        this.deptoDestino = deptoDestino;
        this.residenteQueAutoriza = residenteQueAutoriza;
        this.horaIngreso = LocalDateTime.now();
        this.metodoIngreso = "MANUAL";
    }

    public Long getId() {
        return id;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }

    public String getTipoDocumento() {
        return tipoDocumento;
    }

    public void setTipoDocumento(String tipoDocumento) {
        this.tipoDocumento = tipoDocumento;
    }

    public String getNumeroDocumento() {
        return numeroDocumento;
    }

    public void setNumeroDocumento(String numeroDocumento) {
        this.numeroDocumento = numeroDocumento;
    }

    public String getDeptoDestino() {
        return deptoDestino;
    }

    public void setDeptoDestino(String deptoDestino) {
        this.deptoDestino = deptoDestino;
    }

    public String getResidenteQueAutoriza() {
        return residenteQueAutoriza;
    }

    public void setResidenteQueAutoriza(String residenteQueAutoriza) {
        this.residenteQueAutoriza = residenteQueAutoriza;
    }

    public String getPatenteVehiculo() {
        return patenteVehiculo;
    }

    public void setPatenteVehiculo(String patenteVehiculo) {
        this.patenteVehiculo = patenteVehiculo;
    }

    public String getMetodoIngreso() {
        return metodoIngreso;
    }

    public void setMetodoIngreso(String metodoIngreso) {
        this.metodoIngreso = metodoIngreso;
    }

    public Estacionamiento getEstacionamiento() {
        return estacionamiento;
    }

    public void setEstacionamiento(Estacionamiento estacionamiento) {
        this.estacionamiento = estacionamiento;
    }

    public LocalDateTime getHoraIngreso() {
        return horaIngreso;
    }

    public void setHoraIngreso(LocalDateTime horaIngreso) {
        this.horaIngreso = horaIngreso;
    }

    public LocalDateTime getHoraSalida() {
        return horaSalida;
    }

    public void setHoraSalida(LocalDateTime horaSalida) {
        this.horaSalida = horaSalida;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }
}