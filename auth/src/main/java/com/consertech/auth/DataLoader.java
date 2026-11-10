package com.consertech.auth;

import com.consertech.auth.models.*;
import com.consertech.auth.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

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
    private VisitaRepository visitaRepository;

    @Autowired
    private EncomiendaRepository encomiendaRepository;

    @Autowired
    private BitacoraRepository bitacoraRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {

        // 1. Usuarios Base
        if (usuarioRepository.count() == 0) {
            usuarioRepository.save(new Usuario("admin@admin.com", passwordEncoder.encode("admin123"),
                    "Administrador Sistema", Rol.ROLE_ADMIN));
            usuarioRepository.save(new Usuario("conserje@conserje.com", passwordEncoder.encode("conserje123"),
                    "Juan Pérez (Conserje)", Rol.ROLE_CONSERJE));
            usuarioRepository.save(new Usuario("conserje2@conserje.com", passwordEncoder.encode("conserje123"),
                    "Pedro Morales (Conserje)", Rol.ROLE_CONSERJE));
        }

        // 2. Departamentos (Torres A y B, 4 pisos)
        if (departamentoRepository.count() == 0) {
            List<Departamento> deptos = new ArrayList<>();
            for (String torre : List.of("Torre A", "Torre B")) {
                for (int piso = 1; piso <= 4; piso++) {
                    deptos.add(new Departamento(piso + "01", torre, piso));
                    deptos.add(new Departamento(piso + "02", torre, piso));
                }
            }
            departamentoRepository.saveAll(deptos);
        }

        // 3. Estacionamientos de Visitas (V-01 a V-10)
        if (estacionamientoRepository.count() == 0) {
            for (int i = 1; i <= 10; i++) {
                String codigo = String.format("V-%02d", i);
                estacionamientoRepository.save(new Estacionamiento(codigo, "VISITA", EstadoEstacionamiento.DISPONIBLE));
            }
        }

        // 4. Residentes de prueba
        if (residenteRepository.count() == 0) {
            departamentoRepository.findByNumero("101").ifPresent(d -> residenteRepository.save(new Residente(d,
                    "18.123.456-7", "Carlos", "Mendoza", "carlos.m@gmail.com", "+56911223344", "PROPIETARIO")));
            departamentoRepository.findByNumero("102").ifPresent(d -> residenteRepository.save(new Residente(d,
                    "19.876.543-2", "Camila", "Silva", "camila.s@gmail.com", "+56955667788", "ARRENDATARIO")));
            departamentoRepository.findByNumero("201").ifPresent(d -> residenteRepository.save(new Residente(d,
                    "17.345.678-9", "Rodrigo", "Pérez", "rodrigo.p@gmail.com", "+56999887766", "PROPIETARIO")));
            departamentoRepository.findByNumero("301").ifPresent(d -> residenteRepository.save(new Residente(d,
                    "16.444.555-K", "Valentina", "Rojas", "v.rojas@gmail.com", "+56988776655", "ARRENDATARIO")));
        }

        // 5. Cargar Histórico de Visitas (Últimos 30 días para dashboards de
        // tendencias)
        if (visitaRepository.count() == 0) {
            Random rand = new Random();
            String[] nombres = { "Matías", "Gonzalo", "Felipe", "Sofia", "Ignacia", "Sebastián", "Fernanda", "Diego" };
            String[] apellidos = { "Soto", "Muñoz", "Contreras", "Vargas", "Sepúlveda", "Morales", "Lara", "Gómez" };

            for (int i = 0; i < 60; i++) {
                String nombreVisita = nombres[rand.nextInt(nombres.length)] + " "
                        + apellidos[rand.nextInt(apellidos.length)];
                String rut = (12 + rand.nextInt(8)) + "." + (100 + rand.nextInt(899)) + "." + (100 + rand.nextInt(899))
                        + "-K";
                String deptoDestino = (1 + rand.nextInt(4)) + "0" + (1 + rand.nextInt(2));

                LocalDateTime fechaIngreso = LocalDateTime.now().minusDays(rand.nextInt(30))
                        .minusHours(rand.nextInt(12));
                LocalDateTime fechaSalida = fechaIngreso.plusHours(1 + rand.nextInt(4));

                Visita v = new Visita();
                v.setNombreCompleto(nombreVisita);
                v.setNumeroDocumento(rut);
                v.setTipoDocumento("RUT");
                v.setDeptoDestino(deptoDestino);
                v.setHoraIngreso(fechaIngreso);
                v.setHoraSalida(fechaSalida);

                visitaRepository.save(v);
            }
        }
        // 6. Cargar Histórico de Encomiendas de prueba de forma segura
        if (encomiendaRepository.count() == 0) {
            List<Encomienda> listaEncomiendas = List.of(
                    new Encomienda(),
                    new Encomienda(),
                    new Encomienda());

            // Asignación directa con métodos básicos estándar
            for (int i = 0; i < listaEncomiendas.size(); i++) {
                Encomienda enc = listaEncomiendas.get(i);
                enc.setCourier(i % 2 == 0 ? "Mercado Libre" : "Chilexpress");
                enc.setDeptoDestino(i == 0 ? "101" : i == 1 ? "102" : "201");
                enc.setEstado(i == 0 ? EstadoEncomienda.EN_CONSERJERIA : EstadoEncomienda.ENTREGADO);
                enc.setFechaRecepcion(LocalDateTime.now().minusDays(i + 1));
                encomiendaRepository.save(enc);
            }
        }

        System.out.println(">>> ConserTech: Base de datos cargada exitosamente con registros masivos para Power BI.");
    }
}