package com.consertech.auth.repositories;

import com.consertech.auth.models.BitacoraNovedad;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BitacoraRepository extends JpaRepository<BitacoraNovedad, Long> {
    List<BitacoraNovedad> findAllByOrderByFechaRegistroDesc();
}