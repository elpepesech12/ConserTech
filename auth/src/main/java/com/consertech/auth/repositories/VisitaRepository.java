package com.consertech.auth.repositories;

import com.consertech.auth.models.Visita;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VisitaRepository extends JpaRepository<Visita, Long> {
    // Para listar las visitas más recientes primero en el frontend
    List<Visita> findAllByOrderByHoraIngresoDesc();
}