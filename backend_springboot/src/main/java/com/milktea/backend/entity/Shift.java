package com.milktea.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalTime;

@Entity
@Table(name = "shifts")
public class Shift {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "shift_name", nullable = false)
    private String shiftName; // Ca sáng, Ca chiều, Ca tối

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime;

    @Column(name = "hourly_rate", nullable = false)
    private BigDecimal hourlyRate = new BigDecimal("25000");

    public Shift() {}

    public Shift(String shiftName, LocalTime startTime, LocalTime endTime, BigDecimal hourlyRate) {
        this.shiftName = shiftName;
        this.startTime = startTime;
        this.endTime = endTime;
        this.hourlyRate = hourlyRate;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public LocalTime getEndTime() { return endTime; }
    public void setEndTime(LocalTime endTime) { this.endTime = endTime; }

    public BigDecimal getHourlyRate() { return hourlyRate; }
    public void setHourlyRate(BigDecimal hourlyRate) { this.hourlyRate = hourlyRate; }
}
