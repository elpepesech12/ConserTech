package com.consertech.auth.repositories;

import com.consertech.auth.models.Departamento;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface DepartamentoRepository extends JpaRepository<Departamento, Long> {
    Optional<Departamento> findByNumero(String numero);

    List<Departamento> findByActivoTrueOrderByNumeroAsc();
}