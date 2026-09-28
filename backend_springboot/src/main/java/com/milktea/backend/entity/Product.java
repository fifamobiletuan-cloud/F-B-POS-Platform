package com.milktea.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(name = "category_code", nullable = false)
    private String category; // AnVatMan, DoAnCay, NuocUong, BanhNgot, SnackKeo, TraiCayChua, AnVatHanQuoc, MonNoNhe

    private String subcategory; // tradao, tratac, trasua, cacao, nuocep

    @Column(name = "base_price", nullable = false)
    private BigDecimal basePrice;

    @Column(name = "original_price")
    private BigDecimal originalPrice;

    @Column(name = "image_url")
    private String imageUrl;

    private String description;

    @Column(name = "is_available")
    private Boolean isAvailable = true;

    private BigDecimal rating = new BigDecimal("5.0");

    @Column(name = "sold_count")
    private Integer soldCount = 0;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    public Product() {}

    public Product(String name, String category, String subcategory, BigDecimal basePrice, BigDecimal originalPrice, String imageUrl, String description) {
        this.name = name;
        this.category = category;
        this.subcategory = subcategory;
        this.basePrice = basePrice;
        this.originalPrice = originalPrice;
        this.imageUrl = imageUrl;
        this.description = description;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSubcategory() { return subcategory; }
    public void setSubcategory(String subcategory) { this.subcategory = subcategory; }

    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }

    public BigDecimal getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(BigDecimal originalPrice) { this.originalPrice = originalPrice; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(Boolean isAvailable) { this.isAvailable = isAvailable; }

    public BigDecimal getRating() { return rating; }
    public void setRating(BigDecimal rating) { this.rating = rating; }

    public Integer getSoldCount() { return soldCount; }
    public void setSoldCount(Integer soldCount) { this.soldCount = soldCount; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
