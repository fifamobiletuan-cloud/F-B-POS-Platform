package com.milktea.backend.dto;

import java.math.BigDecimal;

public class DashboardStatsDTO {
    private BigDecimal todayRevenue;
    private long totalOrdersToday;
    private long pendingOrders;
    private long preparingOrders;
    private long completedOrders;
    private int occupiedTables;
    private int totalTables;

    public DashboardStatsDTO() {}

    public BigDecimal getTodayRevenue() { return todayRevenue; }
    public void setTodayRevenue(BigDecimal todayRevenue) { this.todayRevenue = todayRevenue; }

    public long getTotalOrdersToday() { return totalOrdersToday; }
    public void setTotalOrdersToday(long totalOrdersToday) { this.totalOrdersToday = totalOrdersToday; }

    public long getPendingOrders() { return pendingOrders; }
    public void setPendingOrders(long pendingOrders) { this.pendingOrders = pendingOrders; }

    public long getPreparingOrders() { return preparingOrders; }
    public void setPreparingOrders(long preparingOrders) { this.preparingOrders = preparingOrders; }

    public long getCompletedOrders() { return completedOrders; }
    public void setCompletedOrders(long completedOrders) { this.completedOrders = completedOrders; }

    public int getOccupiedTables() { return occupiedTables; }
    public void setOccupiedTables(int occupiedTables) { this.occupiedTables = occupiedTables; }

    public int getTotalTables() { return totalTables; }
    public void setTotalTables(int totalTables) { this.totalTables = totalTables; }
}
