package com.consertech.auth.repositories;

import com.consertech.auth.models.Residente;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ResidenteRepository extends JpaRepository<Residente, Long> {
    Optional<Residente> findByRut(String rut);

    List<Residente> findByDepartamentoId(Long departamentoId);

    List<Residente> findByNombreContainingIgnoreCaseOrApellidoContainingIgnoreCase(String nombre, String apellido);
}