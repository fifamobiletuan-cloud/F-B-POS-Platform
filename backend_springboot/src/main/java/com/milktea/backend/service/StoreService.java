package com.milktea.backend.service;

import com.milktea.backend.dto.DashboardStatsDTO;
import com.milktea.backend.entity.DiningTable;
import com.milktea.backend.entity.Order;
import com.milktea.backend.repository.DiningTableRepository;
import com.milktea.backend.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
public class StoreService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private DiningTableRepository diningTableRepository;

    public DashboardStatsDTO getTodayDashboardStats() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);

        List<Order> todayOrders = orderRepository.findByCreatedAtBetweenOrderByCreatedAtDesc(startOfDay, endOfDay);
        List<DiningTable> allTables = diningTableRepository.findAll();

        BigDecimal todayRevenue = BigDecimal.ZERO;
        long pending = 0;
        long preparing = 0;
        long completed = 0;

        for (Order o : todayOrders) {
            if ("COMPLETED".equalsIgnoreCase(o.getStatus()) || "PAID".equalsIgnoreCase(o.getPaymentStatus())) {
                todayRevenue = todayRevenue.add(o.getFinalAmount());
            }
            if ("PENDING".equalsIgnoreCase(o.getStatus())) pending++;
            else if ("PREPARING".equalsIgnoreCase(o.getStatus())) preparing++;
            else if ("COMPLETED".equalsIgnoreCase(o.getStatus())) completed++;
        }

        int occupiedTables = 0;
        for (DiningTable t : allTables) {
            if ("OCCUPIED".equalsIgnoreCase(t.getStatus())) {
                occupiedTables++;
            }
        }

        DashboardStatsDTO stats = new DashboardStatsDTO();
        stats.setTodayRevenue(todayRevenue);
        stats.setTotalOrdersToday(todayOrders.size());
        stats.setPendingOrders(pending);
        stats.setPreparingOrders(preparing);
        stats.setCompletedOrders(completed);
        stats.setOccupiedTables(occupiedTables);
        stats.setTotalTables(allTables.size());

        return stats;
    }

    public List<DiningTable> getAllTables() {
        return diningTableRepository.findAll();
    }
}
