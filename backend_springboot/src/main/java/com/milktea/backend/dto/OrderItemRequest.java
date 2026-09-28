package com.milktea.backend.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@JsonIgnoreProperties(ignoreUnknown = true)
public class OrderItemRequest {
    private Long productId;
    private String productName;
    private Integer quantity = 1;
    private BigDecimal unitPrice = BigDecimal.ZERO;
    private String note;
    private String size;
    private String sugar;
    private String ice;
    private List<OrderItemToppingRequest> toppings = new ArrayList<>();

    public OrderItemRequest() {}

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public Integer getQuantity() { return quantity != null ? quantity : 1; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public BigDecimal getUnitPrice() { return unitPrice != null ? unitPrice : BigDecimal.ZERO; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }

    public String getSugar() { return sugar; }
    public void setSugar(String sugar) { this.sugar = sugar; }

    public String getIce() { return ice; }
    public void setIce(String ice) { this.ice = ice; }

    public List<OrderItemToppingRequest> getToppings() { return toppings; }

    @SuppressWarnings("unchecked")
    public void setToppings(List<?> rawToppings) {
        this.toppings = new ArrayList<>();
        if (rawToppings == null) return;
        for (Object item : rawToppings) {
            if (item instanceof String) {
                this.toppings.add(new OrderItemToppingRequest((String) item, BigDecimal.valueOf(5000)));
            } else if (item instanceof Map) {
                Map<?, ?> map = (Map<?, ?>) item;
                String name = map.containsKey("toppingName") ? map.get("toppingName").toString() 
                            : (map.containsKey("name") ? map.get("name").toString() : "");
                BigDecimal price = map.containsKey("price") ? new BigDecimal(map.get("price").toString()) : BigDecimal.valueOf(5000);
                this.toppings.add(new OrderItemToppingRequest(name, price));
            } else if (item instanceof OrderItemToppingRequest) {
                this.toppings.add((OrderItemToppingRequest) item);
            }
        }
    }

    public String getFullNote() {
        StringBuilder sb = new StringBuilder();
        if (size != null && !size.isEmpty()) sb.append("Size: ").append(size).append("; ");
        if (sugar != null && !sugar.isEmpty()) sb.append("Đường: ").append(sugar).append("; ");
        if (ice != null && !ice.isEmpty()) sb.append("Đá: ").append(ice).append("; ");
        if (note != null && !note.isEmpty()) sb.append(note);
        return sb.toString().trim();
    }
}
