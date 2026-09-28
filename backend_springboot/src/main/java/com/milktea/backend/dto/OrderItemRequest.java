package com.milktea.backend.dto;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class OrderItemRequest {
    private Long productId;
    private String productName;
    private Integer quantity = 1;
    private BigDecimal unitPrice;
    private String note;
    private List<OrderItemToppingRequest> toppings = new ArrayList<>();

    public OrderItemRequest() {}

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public List<OrderItemToppingRequest> getToppings() { return toppings; }
    public void setToppings(List<OrderItemToppingRequest> toppings) { this.toppings = toppings; }
}
