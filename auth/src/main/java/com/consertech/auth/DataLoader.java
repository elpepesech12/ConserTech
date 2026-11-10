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
            usuarioRepository.save(new Usuario("admin@admin.com", passwordEncoder.encode("admin123"), "Administrador Sistema", Rol.ROLE_ADMIN));
            usuarioRepository.save(new Usuario("conserje@conserje.com", passwordEncoder.encode("conserje123"), "Juan Pérez (Conserje)", Rol.ROLE_CONSERJE));
            usuarioRepository.save(new Usuario("conserje2@conserje.com", passwordEncoder.encode("conserje123"), "Pedro Morales (Conserje)", Rol.ROLE_CONSERJE));
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
            departamentoRepository.findByNumero("101").ifPresent(d -> residenteRepository.save(new Residente(d, "18.123.456-7", "Carlos", "Mendoza", "carlos.m@gmail.com", "+56911223344", "PROPIETARIO")));
            departamentoRepository.findByNumero("102").ifPresent(d -> residenteRepository.save(new Residente(d, "19.876.543-2", "Camila", "Silva", "camila.s@gmail.com", "+56955667788", "ARRENDATARIO")));
            departamentoRepository.findByNumero("201").ifPresent(d -> residenteRepository.save(new Residente(d, "17.345.678-9", "Rodrigo", "Pérez", "rodrigo.p@gmail.com", "+56999887766", "PROPIETARIO")));
            departamentoRepository.findByNumero("301").ifPresent(d -> residenteRepository.save(new Residente(d, "16.444.555-K", "Valentina", "Rojas", "v.rojas@gmail.com", "+56988776655", "ARRENDATARIO")));
        }

        // 5. Cargar Histórico de Visitas (Últimos 30 días para dashboards de tendencias)
        if (visitaRepository.count() == 0) {
            Random rand = new Random();
            String[] nombres = {"Matías", "Gonzalo", "Felipe", "Sofia", "Ignacia", "Sebastián", "Fernanda", "Diego"};
            String[] apellidos = {"Soto", "Muñoz", "Contreras", "Vargas", "Sepúlveda", "Morales", "Lara", "Gómez"};

            for (int i = 0; i < 60; i++) {
                String nombreVisita = nombres[rand.nextInt(nombres.length)] + " " + apellidos[rand.nextInt(apellidos.length)];
                String rut = (12 + rand.nextInt(8)) + "." + (100 + rand.nextInt(899)) + "." + (100 + rand.nextInt(899)) + "-K";
                String deptoDestino = (1 + rand.nextInt(4)) + "0" + (1 + rand.nextInt(2));

                LocalDateTime fechaIngreso = LocalDateTime.now().minusDays(rand.nextInt(30)).minusHours(rand.nextInt(12));
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

        // 6. Cargar Histórico de Encomiendas (Couriers y estados)
        if (encomiendaRepository.count() == 0) {
            Random rand = new Random();
            String[] couriers = {"Mercado Libre", "Chilexpress", "Starken", "Blue Express", "Amazon"};
            String[] receptores = {"Carlos Mendoza", "Camila Silva", "Rodrigo Pérez", "Valentina Rojas"};

            for (int i = 0; i < 40; i++) {
                String courier = couriers[rand.nextInt(couriers.length)];
                String destinatario = receptores[rand.nextInt(receptores.length)];
                String depto = (1 + rand.nextInt(4)) + "0" + (1 + rand.nextInt(2));
                LocalDateTime fechaRec = LocalDateTime.now().minusDays(rand.nextInt(20)).minusHours(rand.nextInt(8));

                Encomienda enc = new Encomienda();
                enc.setCourier(courier);
                enc.setDestinatario(destinatario);
                enc.setDeptoDestino(depto);
                enc.setTrackingNumber("TRK-" + (100000 + rand.nextInt(900000)));
                enc.setFechaRecepcion(fechaRec);

                if (rand.nextBoolean()) {
                    enc.setEstado(EstadoEncomienda.ENTREGADO);
                    enc.setFechaEntrega(fechaRec.plusHours(2 + rand.nextInt(10)));
                    enc.setRetiradoPor(destinatario);
                    enc.setRutRetiro("18.123.456-7");
                } else {
                    enc.setEstado(EstadoEncomienda.EN_CONSERJERIA);
                }

                encomiendaRepository.save(enc);
            }
        }

        System.out.println(">>> ConserTech: Base de datos cargada exitosamente con registros masivos para Power BI.");
    }
}