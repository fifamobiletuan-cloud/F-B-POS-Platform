package com.milktea.backend.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "order_item_toppings")
public class OrderItemTopping {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_item_id", nullable = false)
    @JsonBackReference
    private OrderItem orderItem;

    @Column(name = "topping_name", nullable = false)
    private String toppingName;

    @Column(nullable = false)
    private BigDecimal price;

    public OrderItemTopping() {}

    public OrderItemTopping(String toppingName, BigDecimal price) {
        this.toppingName = toppingName;
        this.price = price;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public OrderItem getOrderItem() { return orderItem; }
    public void setOrderItem(OrderItem orderItem) { this.orderItem = orderItem; }

    public String getToppingName() { return toppingName; }
    public void setToppingName(String toppingName) { this.toppingName = toppingName; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
}
