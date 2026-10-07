package com.smartpayroll.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class LeaveBalance implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int balanceId;
    private int staffId;
    private int year;
    private int sickLeave;
    private int casualLeave;
    private int annualLeave;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // For display
    private String staffName;
    
    // Constructors
    public LeaveBalance() {}
    
    public LeaveBalance(int staffId, int year) {
        this.staffId = staffId;
        this.year = year;
        this.sickLeave = 7;
        this.casualLeave = 7;
        this.annualLeave = 14;
    }
    
    // Getters and Setters
    public int getBalanceId() {
        return balanceId;
    }
    
    public void setBalanceId(int balanceId) {
        this.balanceId = balanceId;
    }
    
    public int getStaffId() {
        return staffId;
    }
    
    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }
    
    public int getYear() {
        return year;
    }
    
    public void setYear(int year) {
        this.year = year;
    }
    
    public int getSickLeave() {
        return sickLeave;
    }
    
    public void setSickLeave(int sickLeave) {
        this.sickLeave = sickLeave;
    }
    
    public int getCasualLeave() {
        return casualLeave;
    }
    
    public void setCasualLeave(int casualLeave) {
        this.casualLeave = casualLeave;
    }
    
    public int getAnnualLeave() {
        return annualLeave;
    }
    
    public void setAnnualLeave(int annualLeave) {
        this.annualLeave = annualLeave;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getStaffName() {
        return staffName;
    }
    
    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }
    
    public int getTotalLeave() {
        return sickLeave + casualLeave + annualLeave;
    }
    
    @Override
    public String toString() {
        return "LeaveBalance [staffId=" + staffId + ", year=" + year + 
               ", sick=" + sickLeave + ", casual=" + casualLeave + 
               ", annual=" + annualLeave + "]";
    }
}