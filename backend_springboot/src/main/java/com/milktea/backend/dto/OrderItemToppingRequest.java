package com.milktea.backend.dto;

import java.math.BigDecimal;

public class OrderItemToppingRequest {
    private String toppingName;
    private BigDecimal price;

    public OrderItemToppingRequest() {}

    public OrderItemToppingRequest(String toppingName, BigDecimal price) {
        this.toppingName = toppingName;
        this.price = price;
    }

    public String getToppingName() { return toppingName; }
    public void setToppingName(String toppingName) { this.toppingName = toppingName; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
}
