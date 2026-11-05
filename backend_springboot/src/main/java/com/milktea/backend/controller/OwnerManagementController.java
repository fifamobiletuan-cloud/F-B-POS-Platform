package com.milktea.backend.controller;

import com.milktea.backend.dto.ApiResponse;
import com.milktea.backend.entity.DiningTable;
import com.milktea.backend.entity.Expense;
import com.milktea.backend.entity.Order;
import com.milktea.backend.entity.OrderItem;
import com.milktea.backend.entity.Product;
import com.milktea.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

@RestController
@RequestMapping("/api/v1/owner")
@CrossOrigin(origins = "*")
public class OwnerManagementController {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private DiningTableRepository diningTableRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ExpenseRepository expenseRepository;

    // 1. Lấy tất cả hàng hóa (cho màn hình Quản lý Hàng hóa KiotViet)
    @GetMapping("/products")
    public ResponseEntity<ApiResponse<List<Product>>> getAllProducts() {
        return ResponseEntity.ok(ApiResponse.ok("Danh sách toàn bộ món ăn", productRepository.findAll()));
    }

    // 2. Bật/Tắt trạng thái còn hàng / hết hàng của món
    @PatchMapping("/products/{id}/toggle")
    public ResponseEntity<ApiResponse<Product>> toggleProductAvailability(@PathVariable Long id) {
        return productRepository.findById(id).map(p -> {
            p.setIsAvailable(!Boolean.TRUE.equals(p.getIsAvailable()));
            p.setUpdatedAt(LocalDateTime.now());
            Product saved = productRepository.save(p);
            return ResponseEntity.ok(ApiResponse.ok("Cập nhật trạng thái món thành công", saved));
        }).orElse(ResponseEntity.notFound().build());
    }

    // 3. Cập nhật thông tin món (Tên, giá bán, nhóm món, mô tả)
    @PutMapping("/products/{id}")
    public ResponseEntity<ApiResponse<Product>> updateProduct(@PathVariable Long id, @RequestBody Product req) {
        return productRepository.findById(id).map(p -> {
            if (req.getName() != null) p.setName(req.getName());
            if (req.getBasePrice() != null) p.setBasePrice(req.getBasePrice());
            if (req.getOriginalPrice() != null) p.setOriginalPrice(req.getOriginalPrice());
            if (req.getCategory() != null) p.setCategory(req.getCategory());
            if (req.getSubcategory() != null) p.setSubcategory(req.getSubcategory());
            if (req.getDescription() != null) p.setDescription(req.getDescription());
            if (req.getImageUrl() != null) p.setImageUrl(req.getImageUrl());
            if (req.getIsAvailable() != null) p.setIsAvailable(req.getIsAvailable());
            p.setUpdatedAt(LocalDateTime.now());
            return ResponseEntity.ok(ApiResponse.ok("Cập nhật món thành công", productRepository.save(p)));
        }).orElse(ResponseEntity.notFound().build());
    }

    // 4. Thêm món mới vào thực đơn
    @PostMapping("/products")
    public ResponseEntity<ApiResponse<Product>> createProduct(@RequestBody Product req) {
        if (req.getName() == null || req.getBasePrice() == null) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Tên món và giá bán không được để trống!"));
        }
        if (req.getCategory() == null) req.setCategory("AnVatMan");
        if (req.getIsAvailable() == null) req.setIsAvailable(true);
        req.setCreatedAt(LocalDateTime.now());
        req.setUpdatedAt(LocalDateTime.now());
        Product saved = productRepository.save(req);
        return ResponseEntity.status(201).body(ApiResponse.ok("Thêm món mới thành công", saved));
    }

    // 5. Xóa món
    @DeleteMapping("/products/{id}")
    public ResponseEntity<ApiResponse<String>> deleteProduct(@PathVariable Long id) {
        if (productRepository.existsById(id)) {
            productRepository.deleteById(id);
            return ResponseEntity.ok(ApiResponse.ok("Đã xóa món thành công"));
        }
        return ResponseEntity.notFound().build();
    }

    // 6. Giải phóng bàn ăn (chuyển sang trống AVAILABLE)
    @PostMapping("/tables/clear/{tableNumber}")
    public ResponseEntity<ApiResponse<DiningTable>> clearTable(@PathVariable String tableNumber) {
        return diningTableRepository.findByTableNumber(tableNumber).map(table -> {
            table.setStatus("AVAILABLE");
            DiningTable saved = diningTableRepository.save(table);
            return ResponseEntity.ok(ApiResponse.ok("Đã giải phóng bàn " + tableNumber, saved));
        }).orElse(ResponseEntity.notFound().build());
    }

    // 7. Cập nhật trạng thái bàn ăn (AVAILABLE, OCCUPIED, RESERVED)
    @PatchMapping("/tables/{tableNumber}/status")
    public ResponseEntity<ApiResponse<DiningTable>> updateTableStatus(
            @PathVariable String tableNumber,
            @RequestParam String status) {
        return diningTableRepository.findByTableNumber(tableNumber).map(table -> {
            table.setStatus(status.toUpperCase());
            DiningTable saved = diningTableRepository.save(table);
            return ResponseEntity.ok(ApiResponse.ok("Cập nhật trạng thái bàn thành công", saved));
        }).orElse(ResponseEntity.notFound().build());
    }

    // 8. Thanh toán đơn hàng & Hoàn thành
    @PostMapping("/invoices/{orderId}/pay")
    public ResponseEntity<ApiResponse<Order>> payInvoice(
            @PathVariable Long orderId,
            @RequestParam(defaultValue = "TIEN_MAT") String paymentMethod) {
        return orderRepository.findById(orderId).map(order -> {
            order.setStatus("COMPLETED");
            order.setPaymentStatus("PAID");
            order.setPaymentMethod(paymentMethod);
            order.setUpdatedAt(LocalDateTime.now());
            Order saved = orderRepository.save(order);

            // Tự động giải phóng bàn
            diningTableRepository.findByTableNumber(order.getTableNumber()).ifPresent(table -> {
                table.setStatus("AVAILABLE");
                diningTableRepository.save(table);
            });

            return ResponseEntity.ok(ApiResponse.ok("Thanh toán hóa đơn #" + order.getOrderCode() + " thành công!", saved));
        }).orElse(ResponseEntity.notFound().build());
    }

    // 9. Thống kê phân tích tổng quan chuyên sâu cho Dashboard KiotViet
    @GetMapping("/analytics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getAnalytics(
            @RequestParam(defaultValue = "today") String period) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);

        List<Order> todayOrders = orderRepository.findByCreatedAtBetweenOrderByCreatedAtDesc(startOfDay, endOfDay);
        List<Order> allOrders = orderRepository.findAll();
        List<Expense> allExpenses = expenseRepository.findAll();
        List<DiningTable> allTables = diningTableRepository.findAll();

        BigDecimal todayRevenue = BigDecimal.ZERO;
        int completedBills = 0;
        int pendingBills = 0;
        int preparingBills = 0;

        // Thống kê theo giờ (08:00 - 22:00)
        Map<Integer, BigDecimal> hourlyRevenue = new TreeMap<>();
        for (int h = 8; h <= 22; h += 2) {
            hourlyRevenue.put(h, BigDecimal.ZERO);
        }

        // Top món bán chạy
        Map<String, Map<String, Object>> productSales = new HashMap<>();

        for (Order o : todayOrders) {
            if ("COMPLETED".equalsIgnoreCase(o.getStatus()) || "PAID".equalsIgnoreCase(o.getPaymentStatus())) {
                todayRevenue = todayRevenue.add(o.getFinalAmount());
                completedBills++;

                if (o.getCreatedAt() != null) {
                    int hour = o.getCreatedAt().getHour();
                    int slot = Math.max(8, Math.min(22, (hour / 2) * 2));
                    hourlyRevenue.put(slot, hourlyRevenue.getOrDefault(slot, BigDecimal.ZERO).add(o.getFinalAmount()));
                }
            }
            if ("PENDING".equalsIgnoreCase(o.getStatus())) pendingBills++;
            else if ("PREPARING".equalsIgnoreCase(o.getStatus())) preparingBills++;

            // Gom chi tiết món
            if (o.getItems() != null) {
                for (OrderItem item : o.getItems()) {
                    String name = item.getProductName();
                    if (name == null || name.isEmpty()) continue;
                    Map<String, Object> stat = productSales.computeIfAbsent(name, k -> {
                        Map<String, Object> map = new HashMap<>();
                        map.put("name", name);
                        map.put("quantity", 0);
                        map.put("revenue", BigDecimal.ZERO);
                        map.put("productId", item.getProductId());
                        return map;
                    });
                    int q = (int) stat.get("quantity") + (item.getQuantity() != null ? item.getQuantity() : 1);
                    BigDecimal rev = ((BigDecimal) stat.get("revenue")).add(item.getSubtotal() != null ? item.getSubtotal() : BigDecimal.ZERO);
                    stat.put("quantity", q);
                    stat.put("revenue", rev);
                }
            }
        }

        // Nếu hôm nay chưa có nhiều món, lấy thêm từ toàn bộ đơn để hiển thị biểu đồ đẹp mắt
        if (productSales.size() < 5) {
            for (Order o : allOrders) {
                if (o.getItems() != null) {
                    for (OrderItem item : o.getItems()) {
                        String name = item.getProductName();
                        if (name == null || name.isEmpty()) continue;
                        Map<String, Object> stat = productSales.computeIfAbsent(name, k -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("name", name);
                            map.put("quantity", 0);
                            map.put("revenue", BigDecimal.ZERO);
                            map.put("productId", item.getProductId());
                            return map;
                        });
                        int q = (int) stat.get("quantity") + (item.getQuantity() != null ? item.getQuantity() : 1);
                        BigDecimal rev = ((BigDecimal) stat.get("revenue")).add(item.getSubtotal() != null ? item.getSubtotal() : BigDecimal.ZERO);
                        stat.put("quantity", q);
                        stat.put("revenue", rev);
                    }
                }
            }
        }

        // Danh sách Top món đã sort
        List<Map<String, Object>> topProducts = new ArrayList<>(productSales.values());
        topProducts.sort((a, b) -> ((Integer) b.get("quantity")).compareTo((Integer) a.get("quantity")));
        if (topProducts.size() > 10) {
            topProducts = topProducts.subList(0, 10);
        }

        // Chi phí hôm nay
        BigDecimal todayExpense = BigDecimal.ZERO;
        for (Expense e : allExpenses) {
            if (e.getDate() != null && e.getDate().equals(LocalDate.now())) {
                todayExpense = todayExpense.add(e.getAmount());
            }
        }

        BigDecimal netProfit = todayRevenue.subtract(todayExpense);

        // Bàn hoạt động
        int occupiedTables = 0;
        for (DiningTable t : allTables) {
            if ("OCCUPIED".equalsIgnoreCase(t.getStatus())) {
                occupiedTables++;
            }
        }

        Map<String, Object> data = new HashMap<>();
        data.put("date", LocalDate.now().toString());
        data.put("todayRevenue", todayRevenue);
        data.put("todayExpense", todayExpense);
        data.put("netProfit", netProfit);
        data.put("totalOrdersToday", todayOrders.size());
        data.put("completedBills", completedBills);
        data.put("pendingBills", pendingBills);
        data.put("preparingBills", preparingBills);
        data.put("occupiedTables", occupiedTables);
        data.put("totalTables", allTables.size());
        data.put("hourlyRevenue", hourlyRevenue);
        data.put("topProducts", topProducts);
        data.put("expenses", allExpenses);

        return ResponseEntity.ok(ApiResponse.ok("Dữ liệu phân tích Dashboard KiotViet FnB", data));
    }
}
