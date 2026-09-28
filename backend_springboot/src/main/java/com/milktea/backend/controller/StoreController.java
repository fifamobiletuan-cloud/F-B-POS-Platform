package com.milktea.backend.controller;

import com.milktea.backend.dto.ApiResponse;
import com.milktea.backend.dto.DashboardStatsDTO;
import com.milktea.backend.dto.UpdateOrderStatusRequest;
import com.milktea.backend.entity.DiningTable;
import com.milktea.backend.entity.Order;
import com.milktea.backend.service.OrderService;
import com.milktea.backend.service.StoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/store")
@CrossOrigin(origins = "*") // Hỗ trợ App Quán / App Bếp gọi API
public class StoreController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private StoreService storeService;

    // API 1: Lấy tất cả đơn hàng (cho Thu ngân / Quản lý)
    @GetMapping("/orders")
    public ResponseEntity<ApiResponse<List<Order>>> getAllOrders() {
        return ResponseEntity.ok(ApiResponse.ok(orderService.getAllOrders()));
    }

    // API 2: Lấy danh sách món đang chờ làm & đang làm (Dành riêng cho màn hình Bếp - KDS App)
    @GetMapping("/kitchen/orders")
    public ResponseEntity<ApiResponse<List<Order>>> getKitchenOrders() {
        return ResponseEntity.ok(ApiResponse.ok("Danh sách đơn cần chế biến", orderService.getKitchenOrders()));
    }

    // API 3: Bếp / Nhân viên cập nhật trạng thái đơn (PENDING -> PREPARING -> SERVED -> COMPLETED)
    @PatchMapping("/orders/{orderId}/status")
    public ResponseEntity<ApiResponse<Order>> updateOrderStatus(
            @PathVariable Long orderId,
            @RequestBody UpdateOrderStatusRequest request) {
        Order updatedOrder = orderService.updateStatus(orderId, request);
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật trạng thái đơn hàng thành công!", updatedOrder));
    }

    // API 4: Sơ đồ bàn ăn trực tiếp theo thời gian thực (Bàn nào đang có khách, bàn nào trống)
    @GetMapping("/tables")
    public ResponseEntity<ApiResponse<List<DiningTable>>> getAllTables() {
        return ResponseEntity.ok(ApiResponse.ok(storeService.getAllTables()));
    }

    // API 5: Thống kê doanh thu, số đơn, trạng thái bàn hôm nay (Cho Chủ quán / Thu ngân)
    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<DashboardStatsDTO>> getDashboard() {
        return ResponseEntity.ok(ApiResponse.ok(storeService.getTodayDashboardStats()));
    }
}
