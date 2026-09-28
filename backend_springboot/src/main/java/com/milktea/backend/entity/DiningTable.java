package com.milktea.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "dining_tables")
public class DiningTable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "table_number", unique = true, nullable = false)
    private String tableNumber; // Bàn 01 -> Bàn 12

    @Column(name = "qr_token")
    private String qrToken;

    @Column(nullable = false)
    private String status = "AVAILABLE"; // AVAILABLE, OCCUPIED, RESERVED

    private Integer capacity = 4;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public DiningTable() {}

    public DiningTable(String tableNumber, String qrToken, String status, Integer capacity) {
        this.tableNumber = tableNumber;
        this.qrToken = qrToken;
        this.status = status;
        this.capacity = capacity;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTableNumber() { return tableNumber; }
    public void setTableNumber(String tableNumber) { this.tableNumber = tableNumber; }

    public String getQrToken() { return qrToken; }
    public void setQrToken(String qrToken) { this.qrToken = qrToken; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
