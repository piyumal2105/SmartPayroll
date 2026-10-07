package com.smartpayroll.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Payroll {
    private int payrollId;
    private int staffId;
    private String staffName;
    private String staffEmail;
    private String month;
    private int year;
    private BigDecimal basicSalary;
    private BigDecimal bonus;
    private BigDecimal deductions;
    private BigDecimal netSalary;
    private String status; // PENDING, PROCESSED, PAID
    private LocalDateTime createdAt;
    private LocalDateTime processedAt;

    // Constructors
    public Payroll() {
        this.bonus = BigDecimal.ZERO;
        this.deductions = BigDecimal.ZERO;
        this.status = "PENDING";
    }

    public Payroll(int staffId, String month, int year, BigDecimal basicSalary, 
                   BigDecimal bonus, BigDecimal deductions) {
        this.staffId = staffId;
        this.month = month;
        this.year = year;
        this.basicSalary = basicSalary;
        this.bonus = bonus != null ? bonus : BigDecimal.ZERO;
        this.deductions = deductions != null ? deductions : BigDecimal.ZERO;
        this.netSalary = calculateNetSalary();
        this.status = "PENDING";
    }

    // Calculate net salary automatically
    public BigDecimal calculateNetSalary() {
        BigDecimal gross = basicSalary.add(bonus);
        return gross.subtract(deductions);
    }

    // Update net salary when values change
    public void updateNetSalary() {
        this.netSalary = calculateNetSalary();
    }

    // Getters and Setters
    public int getPayrollId() { return payrollId; }
    public void setPayrollId(int payrollId) { this.payrollId = payrollId; }

    public int getStaffId() { return staffId; }
    public void setStaffId(int staffId) { this.staffId = staffId; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    public String getStaffEmail() { return staffEmail; }
    public void setStaffEmail(String staffEmail) { this.staffEmail = staffEmail; }

    public String getMonth() { return month; }
    public void setMonth(String month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public BigDecimal getBasicSalary() { return basicSalary; }
    public void setBasicSalary(BigDecimal basicSalary) { 
        this.basicSalary = basicSalary;
        updateNetSalary();
    }

    public BigDecimal getBonus() { return bonus; }
    public void setBonus(BigDecimal bonus) { 
        this.bonus = bonus != null ? bonus : BigDecimal.ZERO;
        updateNetSalary();
    }

    public BigDecimal getDeductions() { return deductions; }
    public void setDeductions(BigDecimal deductions) { 
        this.deductions = deductions != null ? deductions : BigDecimal.ZERO;
        updateNetSalary();
    }

    public BigDecimal getNetSalary() { return netSalary; }
    public void setNetSalary(BigDecimal netSalary) { this.netSalary = netSalary; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getProcessedAt() { return processedAt; }
    public void setProcessedAt(LocalDateTime processedAt) { this.processedAt = processedAt; }
}