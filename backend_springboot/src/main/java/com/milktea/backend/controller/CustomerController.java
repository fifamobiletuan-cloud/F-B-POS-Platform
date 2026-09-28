package com.milktea.backend.controller;

import com.milktea.backend.dto.ApiResponse;
import com.milktea.backend.dto.CreateOrderRequest;
import com.milktea.backend.entity.*;
import com.milktea.backend.repository.*;
import com.milktea.backend.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/v1/customer")
@CrossOrigin(origins = "*") // Hỗ trợ Flutter Web và Mobile app gọi API
public class CustomerController {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private ProductOptionRepository productOptionRepository;

    @Autowired
    private DiningTableRepository diningTableRepository;

    @Autowired
    private OrderService orderService;

    // API 1: Khách lấy toàn bộ danh sách thực đơn món ăn từ Cơ sở dữ liệu
    @GetMapping("/menu")
    public ResponseEntity<ApiResponse<List<Product>>> getMenu(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String subcategory,
            @RequestParam(required = false) String search) {
        
        List<Product> products;
        if (search != null && !search.trim().isEmpty()) {
            products = productRepository.searchProducts(search.trim());
        } else if (category != null && !category.equalsIgnoreCase("All")) {
            if (subcategory != null && !subcategory.trim().isEmpty()) {
                products = productRepository.findByCategoryAndSubcategory(category, subcategory);
            } else {
                products = productRepository.findByCategory(category);
            }
        } else {
            products = productRepository.findByIsAvailableTrue();
        }
        return ResponseEntity.ok(ApiResponse.ok(products));
    }

    // API 2: Lấy danh sách các danh mục món ăn
    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<Category>>> getCategories() {
        return ResponseEntity.ok(ApiResponse.ok(categoryRepository.findByIsActiveTrueOrderByDisplayOrderAsc()));
    }

    // API 3: Lấy danh sách Topping thêm
    @GetMapping("/toppings")
    public ResponseEntity<ApiResponse<List<ProductOption>>> getToppings() {
        return ResponseEntity.ok(ApiResponse.ok(productOptionRepository.findByIsAvailableTrue()));
    }

    // API 4: Xác thực thông tin bàn khi khách quét mã QR
    @GetMapping("/tables/{tableNumber}")
    public ResponseEntity<ApiResponse<DiningTable>> verifyTable(@PathVariable String tableNumber) {
        Optional<DiningTable> table = diningTableRepository.findByTableNumber(tableNumber);
        if (table.isPresent()) {
            return ResponseEntity.ok(ApiResponse.ok("Bàn hợp lệ", table.get()));
        } else {
            // Tự động tạo bàn nếu chưa có trong DB (để linh hoạt khi demo)
            DiningTable newTable = new DiningTable(tableNumber, "token_" + tableNumber, "AVAILABLE", 4);
            return ResponseEntity.ok(ApiResponse.ok("Bàn hợp lệ", diningTableRepository.save(newTable)));
        }
    }

    // API 5: Khách gửi đơn đặt món từ bàn -> Ghi trực tiếp vào Database!
    @PostMapping("/orders")
    public ResponseEntity<ApiResponse<Order>> createOrder(@RequestBody CreateOrderRequest request) {
        if (request.getItems() == null || request.getItems().isEmpty()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Đơn hàng phải có ít nhất 1 món!"));
        }
        Order savedOrder = orderService.createOrder(request);
        return ResponseEntity.status(201).body(ApiResponse.ok("Đặt món thành công! Đơn hàng đã được gửi tới bếp.", savedOrder));
    }

    // API 6: Khách theo dõi tiến độ đơn hàng tại bàn
    @GetMapping("/orders/{orderId}")
    public ResponseEntity<ApiResponse<Order>> getOrderStatus(@PathVariable Long orderId) {
        return orderService.getOrderById(orderId)
                .map(order -> ResponseEntity.ok(ApiResponse.ok(order)))
                .orElse(ResponseEntity.notFound().build());
    }

    // API 7: Khách xem các đơn đã đặt của bàn mình
    @GetMapping("/orders/by-table/{tableNumber}")
    public ResponseEntity<ApiResponse<List<Order>>> getOrdersByTable(@PathVariable String tableNumber) {
        return ResponseEntity.ok(ApiResponse.ok(orderService.getOrdersByTable(tableNumber)));
    }
}
