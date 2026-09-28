package com.milktea.backend.dto;

public class UpdateOrderStatusRequest {
    private String status; // PENDING, PREPARING, SERVED, COMPLETED, CANCELLED
    private String paymentStatus; // UNPAID, PAID

    public UpdateOrderStatusRequest() {}

    public UpdateOrderStatusRequest(String status) {
        this.status = status;
    }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
}
