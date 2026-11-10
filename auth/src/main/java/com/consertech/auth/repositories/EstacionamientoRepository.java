package com.consertech.auth.repositories;

import com.consertech.auth.models.Estacionamiento;
import com.consertech.auth.models.EstadoEstacionamiento;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface EstacionamientoRepository extends JpaRepository<Estacionamiento, Long> {
    Optional<Estacionamiento> findByCodigo(String codigo);

    List<Estacionamiento> findByEstado(EstadoEstacionamiento estado);

    long countByEstado(EstadoEstacionamiento estado);
}