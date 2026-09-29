package com.milktea.backend.repository;

import com.milktea.backend.entity.WorkSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface WorkScheduleRepository extends JpaRepository<WorkSchedule, Long> {
    List<WorkSchedule> findByWorkDate(LocalDate date);
    List<WorkSchedule> findByUserIdAndWorkDate(Long userId, LocalDate date);
    Optional<WorkSchedule> findFirstByUserIdAndStatus(Long userId, String status);
}
