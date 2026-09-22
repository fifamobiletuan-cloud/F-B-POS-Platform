package com.milktea.backend.controller;

import com.milktea.backend.entity.Order;
import com.milktea.backend.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/staff")
@CrossOrigin(origins = "*")
public class StaffController {

    @Autowired
    private OrderRepository orderRepository;

    // API 1: Nhân viên xem danh sách các đơn chờ pha chế
    @GetMapping("/orders")
    public ResponseEntity<List<Order>> getOrders() {
        return ResponseEntity.ok(orderRepository.findAll());
    }

    // API 2: Cập nhật tiến độ pha chế (Đang làm -> Hoàn thành)
    @PatchMapping("/orders/{id}/status")
    public ResponseEntity<Order> updateOrderStatus(@PathVariable Long id, @RequestParam String status) {
        return orderRepository.findById(id).map(order -> {
            order.setStatus(status);
            return ResponseEntity.ok(orderRepository.save(order));
        }).orElse(ResponseEntity.notFound().build());
    }
}
