package com.milktea.backend.controller;

import com.milktea.backend.entity.Order;
import com.milktea.backend.entity.Product;
import com.milktea.backend.repository.OrderRepository;
import com.milktea.backend.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("/api/v1/customer")
@CrossOrigin(origins = "*") // Hỗ trợ Flutter Web gọi API
public class CustomerController {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private OrderRepository orderRepository;

    // API 1: Khách lấy danh sách thực đơn món ăn
    @GetMapping("/menu")
    public ResponseEntity<List<Product>> getMenu() {
        List<Product> products = productRepository.findAll();
        if (products.isEmpty()) {
            // Mẫu dữ liệu ban đầu nếu CSDL trống
            products = Arrays.asList(
                new Product("Trà Sữa Ô Long Nướng", "TraSua", new BigDecimal("35000"), "https://images.unsplash.com/photo-1558857563-b371033873b8?w=300", "Vị ô long nướng đậm đà kem béo"),
                new Product("Trà Sữa Trân Châu Hoàng Gia", "TraSua", new BigDecimal("39000"), "https://images.unsplash.com/photo-1541658016709-82535e94bc69?w=300", "Trân châu đen truyền thống"),
                new Product("Trà Đào Cam Sả", "TraTraiCay", new BigDecimal("38000"), "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=300", "Trà đào thơm nồng hương sả"),
                new Product("Bánh Tráng Trộn Sài Gòn", "AnVat", new BigDecimal("25000"), "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300", "Bò khô xoài bào chua cay")
            );
            productRepository.saveAll(products);
        }
        return ResponseEntity.ok(products);
    }

    // API 2: Đọc mã QR token bàn
    @GetMapping("/tables/{token}")
    public ResponseEntity<Map<String, String>> verifyTableQR(@PathVariable String token) {
        Map<String, String> response = new HashMap<>();
        response.put("tableNumber", "Bàn 05");
        response.put("status", "VALID");
        return ResponseEntity.ok(response);
    }

    // API 3: Khách đặt món từ bàn
    @PostMapping("/orders")
    public ResponseEntity<Order> createOrder(@RequestBody Order order) {
        order.setStatus("PENDING");
        Order savedOrder = orderRepository.save(order);
        return ResponseEntity.status(201).body(savedOrder);
    }
}
