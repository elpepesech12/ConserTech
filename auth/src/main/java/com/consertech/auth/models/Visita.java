package com.consertech.auth.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "visitas")
public class Visita {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nombreCompleto;

    @Column(nullable = false)
    private String tipoDocumento; // "RUT", "Pasaporte", u "Otro: Especificado"

    @Column(nullable = false)
    private String numeroDocumento;

    @Column(nullable = false)
    private String deptoDestino;

    private String residenteQueAutoriza;

    @Column(nullable = false)
    private LocalDateTime horaIngreso;

    private LocalDateTime horaSalida;

    public Visita() {}

    public Visita(String nombreCompleto, String tipoDocumento, String numeroDocumento, 
                  String deptoDestino, String residenteQueAutoriza) {
        this.nombreCompleto = nombreCompleto;
        this.tipoDocumento = tipoDocumento;
        this.numeroDocumento = numeroDocumento;
        this.deptoDestino = deptoDestino;
        this.residenteQueAutoriza = residenteQueAutoriza;
        this.horaIngreso = LocalDateTime.now();
    }

    // Getters y Setters
    public Long getId() { return id; }
    public String getNombreCompleto() { return nombreCompleto; }
    public void setNombreCompleto(String nombreCompleto) { this.nombreCompleto = nombreCompleto; }
    public String getTipoDocumento() { return tipoDocumento; }
    public void setTipoDocumento(String tipoDocumento) { this.tipoDocumento = tipoDocumento; }
    public String getNumeroDocumento() { return numeroDocumento; }
    public void setNumeroDocumento(String numeroDocumento) { this.numeroDocumento = numeroDocumento; }
    public String getDeptoDestino() { return deptoDestino; }
    public void setDeptoDestino(String deptoDestino) { this.deptoDestino = deptoDestino; }
    public String getResidenteQueAutoriza() { return residenteQueAutoriza; }
    public void setResidenteQueAutoriza(String residenteQueAutoriza) { this.residenteQueAutoriza = residenteQueAutoriza; }
    public LocalDateTime getHoraIngreso() { return horaIngreso; }
    public void setHoraIngreso(LocalDateTime horaIngreso) { this.horaIngreso = horaIngreso; }
    public LocalDateTime getHoraSalida() { return horaSalida; }
    public void setHoraSalida(LocalDateTime horaSalida) { this.horaSalida = horaSalida; }
}