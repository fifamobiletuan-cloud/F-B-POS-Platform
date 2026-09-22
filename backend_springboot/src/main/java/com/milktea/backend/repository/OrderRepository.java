package com.milktea.backend.repository;

import com.milktea.backend.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByTableNumber(String tableNumber);
    List<Order> findByStatus(String status);
}
