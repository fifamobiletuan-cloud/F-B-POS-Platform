package com.milktea.backend.repository;

import com.milktea.backend.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    Optional<Order> findByOrderCode(String orderCode);

    List<Order> findByTableNumber(String tableNumber);

    List<Order> findByStatus(String status);

    List<Order> findByStatusIn(List<String> statuses);

    // Cho app bếp: lấy các đơn đang chờ làm hoặc đang làm (sắp xếp đơn cũ nhất lên đầu để làm trước)
    List<Order> findByStatusInOrderByCreatedAtAsc(List<String> statuses);

    // Cho app thu ngân / quản lý: lấy tất cả đơn mới nhất lên đầu
    List<Order> findAllByOrderByCreatedAtDesc();

    // Lấy các đơn hôm nay
    List<Order> findByCreatedAtBetweenOrderByCreatedAtDesc(LocalDateTime start, LocalDateTime end);

    @Query("SELECT COUNT(o) FROM Order o WHERE o.status = :status")
    long countByStatus(@Param("status") String status);
}
