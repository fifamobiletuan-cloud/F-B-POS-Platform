package com.milktea.backend.dto;

import java.util.ArrayList;
import java.util.List;

public class CreateOrderRequest {
    private String tableNumber; // ví dụ: Bàn 05
    private Integer discountPercent = 0; // % giảm giá từ vòng quay may mắn
    private String paymentMethod = "VIETQR"; // VIETQR, CASH, MOMO
    private String customerNotes;
    private List<OrderItemRequest> items = new ArrayList<>();

    public CreateOrderRequest() {}

    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }

    public Integer getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(Integer discountPercent) { this.discountPercent = discountPercent; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getCustomerNotes() { return customerNotes; }
    public void setCustomerNotes(String customerNotes) { this.customerNotes = customerNotes; }

    public List<OrderItemRequest> getItems() { return items; }
    public void setItems(List<OrderItemRequest> items) { this.items = items; }
}
