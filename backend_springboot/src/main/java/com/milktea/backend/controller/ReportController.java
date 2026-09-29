package com.milktea.backend.controller;

import com.milktea.backend.dto.ApiResponse;
import com.milktea.backend.entity.Expense;
import com.milktea.backend.entity.Order;
import com.milktea.backend.repository.ExpenseRepository;
import com.milktea.backend.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

@RestController
@RequestMapping("/api/v1/reports")
@CrossOrigin(origins = "*")
public class ReportController {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ExpenseRepository expenseRepository;

    // API: Báo cáo Doanh thu, Chi phí và Lợi nhuận thực tế (Chuẩn mục 4.2 trong Báo cáo)
    @GetMapping("/profit")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getProfitReport() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);

        List<Order> todayOrders = orderRepository.findByCreatedAtBetweenOrderByCreatedAtDesc(startOfDay, endOfDay);
        List<Expense> allExpenses = expenseRepository.findAll();

        BigDecimal todayRevenue = BigDecimal.ZERO;
        for (Order o : todayOrders) {
            if ("COMPLETED".equalsIgnoreCase(o.getStatus()) || "PAID".equalsIgnoreCase(o.getPaymentStatus())) {
                todayRevenue = todayRevenue.add(o.getFinalAmount());
            }
        }

        BigDecimal todayExpense = BigDecimal.ZERO;
        for (Expense e : allExpenses) {
            if (e.getDate() != null && e.getDate().equals(LocalDate.now())) {
                todayExpense = todayExpense.add(e.getAmount());
            }
        }

        BigDecimal netProfit = todayRevenue.subtract(todayExpense);

        Map<String, Object> data = new HashMap<>();
        data.put("date", LocalDate.now().toString());
        data.put("todayRevenue", todayRevenue);
        data.put("todayExpense", todayExpense);
        data.put("netProfit", netProfit);
        data.put("totalOrdersToday", todayOrders.size());
        data.put("expensesList", allExpenses);

        return ResponseEntity.ok(ApiResponse.ok("Báo cáo lợi nhuận quán hôm nay", data));
    }
}
