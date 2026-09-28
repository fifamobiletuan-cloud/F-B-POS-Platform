package com.milktea.backend.service;

import com.milktea.backend.dto.*;
import com.milktea.backend.entity.*;
import com.milktea.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private DiningTableRepository diningTableRepository;

    @Transactional
    public Order createOrder(CreateOrderRequest request) {
        Order order = new Order();
        
        // 1. Tạo mã đơn hàng duy nhất: CC-yyyyMMdd-XXXX
        String dateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String randStr = String.format("%04d", new Random().nextInt(10000));
        order.setOrderCode("CC-" + dateStr + "-" + randStr);

        order.setTableNumber(request.getTableNumber());
        order.setPaymentMethod(request.getPaymentMethod() != null ? request.getPaymentMethod() : "VIETQR");
        order.setPaymentStatus("UNPAID");
        order.setStatus("PENDING");
        order.setCustomerNotes(request.getCustomerNotes());
        order.setDiscountPercent(request.getDiscountPercent() != null ? request.getDiscountPercent() : 0);

        // 2. Tính tiền các món và topping
        BigDecimal totalAmount = BigDecimal.ZERO;

        if (request.getItems() != null) {
            for (OrderItemRequest itemReq : request.getItems()) {
                OrderItem item = new OrderItem();
                item.setProductId(itemReq.getProductId());
                item.setProductName(itemReq.getProductName());
                item.setQuantity(itemReq.getQuantity() != null ? itemReq.getQuantity() : 1);
                item.setUnitPrice(itemReq.getUnitPrice() != null ? itemReq.getUnitPrice() : BigDecimal.ZERO);
                item.setNote(itemReq.getNote());

                BigDecimal itemPrice = item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                BigDecimal toppingsTotal = BigDecimal.ZERO;

                if (itemReq.getToppings() != null) {
                    for (OrderItemToppingRequest topReq : itemReq.getToppings()) {
                        OrderItemTopping topping = new OrderItemTopping(
                            topReq.getToppingName(),
                            topReq.getPrice() != null ? topReq.getPrice() : BigDecimal.ZERO
                        );
                        item.addTopping(topping);
                        toppingsTotal = toppingsTotal.add(topping.getPrice());
                    }
                }

                // Tổng tiền món = (Giá món + Giá topping) * Số lượng
                BigDecimal itemSubtotal = itemPrice.add(toppingsTotal.multiply(BigDecimal.valueOf(item.getQuantity())));
                item.setSubtotal(itemSubtotal);
                totalAmount = totalAmount.add(itemSubtotal);

                order.addItem(item);
            }
        }

        order.setTotalAmount(totalAmount);

        // 3. Tính giảm giá theo voucher vòng quay may mắn
        BigDecimal discountAmount = BigDecimal.ZERO;
        if (order.getDiscountPercent() > 0) {
            discountAmount = totalAmount.multiply(BigDecimal.valueOf(order.getDiscountPercent()))
                    .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
        }
        order.setDiscountAmount(discountAmount);
        order.setFinalAmount(totalAmount.subtract(discountAmount));

        // 4. Lưu đơn vào Database
        Order savedOrder = orderRepository.save(order);

        // 5. Cập nhật trạng thái bàn ăn sang 'OCCUPIED' (Có khách)
        if (request.getTableNumber() != null) {
            diningTableRepository.findByTableNumber(request.getTableNumber()).ifPresent(table -> {
                table.setStatus("OCCUPIED");
                diningTableRepository.save(table);
            });
        }

        return savedOrder;
    }

    public List<Order> getAllOrders() {
        return orderRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<Order> getKitchenOrders() {
        // Trả về các đơn PENDING (Chờ nhận) và PREPARING (Đang làm món) cho Bếp
        return orderRepository.findByStatusInOrderByCreatedAtAsc(Arrays.asList("PENDING", "PREPARING"));
    }

    public Optional<Order> getOrderById(Long id) {
        return orderRepository.findById(id);
    }

    public List<Order> getOrdersByTable(String tableNumber) {
        return orderRepository.findByTableNumber(tableNumber);
    }

    @Transactional
    public Order updateStatus(Long orderId, UpdateOrderStatusRequest request) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng ID: " + orderId));

        if (request.getStatus() != null) {
            order.setStatus(request.getStatus().toUpperCase());
            order.setUpdatedAt(LocalDateTime.now());

            // Nếu đơn hoàn tất (COMPLETED) hoặc hủy (CANCELLED), kiểm tra giải phóng bàn
            if ("COMPLETED".equalsIgnoreCase(request.getStatus()) || "CANCELLED".equalsIgnoreCase(request.getStatus())) {
                diningTableRepository.findByTableNumber(order.getTableNumber()).ifPresent(table -> {
                    table.setStatus("AVAILABLE");
                    diningTableRepository.save(table);
                });
            }
        }

        if (request.getPaymentStatus() != null) {
            order.setPaymentStatus(request.getPaymentStatus().toUpperCase());
        }

        return orderRepository.save(order);
    }
}
