package com.consertech.auth;

import com.consertech.auth.models.*;

import com.consertech.auth.repositories.*;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.boot.CommandLineRunner;

import org.springframework.security.crypto.password.PasswordEncoder;

import org.springframework.stereotype.Component;

import java.util.List;

@Component

public class DataLoader implements CommandLineRunner {

    @Autowired

    private DepartamentoRepository departamentoRepository;

    @Autowired

    private EstacionamientoRepository estacionamientoRepository;

    @Autowired

    private ResidenteRepository residenteRepository;

    @Autowired

    private UsuarioRepository usuarioRepository;

    @Autowired

    private PasswordEncoder passwordEncoder;

    @Override

    public void run(String... args) throws Exception {

        // 1. Cargar Usuarios base

        if (usuarioRepository.count() == 0) {

            usuarioRepository.save(new Usuario(

                    "admin@admin.com",

                    passwordEncoder.encode("admin123"),

                    "Administrador Sistema",

                    Rol.ROLE_ADMIN));

            usuarioRepository.save(new Usuario(

                    "conserje@conserje.com",

                    passwordEncoder.encode("conserje123"),

                    "Conserje Turno",

                    Rol.ROLE_CONSERJE));

        }

        // 2. Cargar Departamentos

        if (departamentoRepository.count() == 0) {

            departamentoRepository.saveAll(List.of(

                    new Departamento("101", "Torre A", 1),

                    new Departamento("102", "Torre A", 1),

                    new Departamento("201", "Torre A", 2),

                    new Departamento("202", "Torre A", 2),

                    new Departamento("301", "Torre B", 3),

                    new Departamento("302", "Torre B", 3),

                    new Departamento("401", "Torre B", 4),

                    new Departamento("402", "Torre B", 4)));

        }

        // 3. Cargar Estacionamientos de Visitas

        if (estacionamientoRepository.count() == 0) {

            for (int i = 1; i <= 10; i++) {

                String codigo = String.format("V-%02d", i);

                estacionamientoRepository.save(

                        new Estacionamiento(codigo, "VISITA", EstadoEstacionamiento.DISPONIBLE));

            }

        }

        // 4. Cargar Residentes de prueba

        if (residenteRepository.count() == 0) {

            departamentoRepository.findByNumero("101").ifPresent(d101 -> residenteRepository.save(new Residente(d101,

                    "18.123.456-7", "Carlos", "Mendoza", "carlos.m@gmail.com", "+56911223344", "PROPIETARIO")));

            departamentoRepository.findByNumero("102").ifPresent(d102 -> residenteRepository.save(new Residente(d102,

                    "19.876.543-2", "Camila", "Silva", "camila.s@gmail.com", "+56955667788", "ARRENDATARIO")));

            departamentoRepository.findByNumero("201").ifPresent(d201 -> residenteRepository.save(new Residente(d201,

                    "17.345.678-9", "Rodrigo", "Pérez", "rodrigo.p@gmail.com", "+56999887766", "PROPIETARIO")));

        }

        System.out.println(">>> ConserTech: Base de datos y datos iniciales inicializados con éxito.");

    }

}