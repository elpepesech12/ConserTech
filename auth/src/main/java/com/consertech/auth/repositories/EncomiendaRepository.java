package com.consertech.auth.repositories;

import com.consertech.auth.models.Encomienda;
import com.consertech.auth.models.EstadoEncomienda;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface EncomiendaRepository extends JpaRepository<Encomienda, Long> {
    List<Encomienda> findByEstadoOrderByFechaRecepcionDesc(EstadoEncomienda estado);

    List<Encomienda> findByDeptoDestinoOrderByFechaRecepcionDesc(String deptoDestino);

    long countByEstado(EstadoEncomienda estado);
}