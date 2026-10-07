package com.smartpayroll.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

public class Leave implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int leaveId;
    private int staffId;
    private String leaveType; // SICK, CASUAL, ANNUAL, EMERGENCY, OTHER
    private Date startDate;
    private Date endDate;
    private String reason;
    private String status; // PENDING, APPROVED, REJECTED
    private Integer approvedBy;
    private Date approvedDate;
    private String remarks;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // For displaying with staff info
    private String staffName;
    private String staffEmail;
    private String approverName;
    
    // Constructors
    public Leave() {}
    
    public Leave(int staffId, String leaveType, Date startDate, Date endDate, String reason) {
        this.staffId = staffId;
        this.leaveType = leaveType;
        this.startDate = startDate;
        this.endDate = endDate;
        this.reason = reason;
        this.status = "PENDING";
    }
    
    // Getters and Setters
    public int getLeaveId() {
        return leaveId;
    }
    
    public void setLeaveId(int leaveId) {
        this.leaveId = leaveId;
    }
    
    public int getStaffId() {
        return staffId;
    }
    
    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }
    
    public String getLeaveType() {
        return leaveType;
    }
    
    public void setLeaveType(String leaveType) {
        this.leaveType = leaveType;
    }
    
    public Date getStartDate() {
        return startDate;
    }
    
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }
    
    public Date getEndDate() {
        return endDate;
    }
    
    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
    
    public String getReason() {
        return reason;
    }
    
    public void setReason(String reason) {
        this.reason = reason;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Integer getApprovedBy() {
        return approvedBy;
    }
    
    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }
    
    public Date getApprovedDate() {
        return approvedDate;
    }
    
    public void setApprovedDate(Date approvedDate) {
        this.approvedDate = approvedDate;
    }
    
    public String getRemarks() {
        return remarks;
    }
    
    public void setRemarks(String remarks) {
        this.remarks = remarks;
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
    
    public String getStaffEmail() {
        return staffEmail;
    }
    
    public void setStaffEmail(String staffEmail) {
        this.staffEmail = staffEmail;
    }
    
    public String getApproverName() {
        return approverName;
    }
    
    public void setApproverName(String approverName) {
        this.approverName = approverName;
    }
    
    // Calculate duration in days
    public int getDurationDays() {
        if (startDate != null && endDate != null) {
            long diff = endDate.getTime() - startDate.getTime();
            return (int) (diff / (1000 * 60 * 60 * 24)) + 1;
        }
        return 0;
    }
    
    @Override
    public String toString() {
        return "Leave [leaveId=" + leaveId + ", staffId=" + staffId + 
               ", type=" + leaveType + ", status=" + status + "]";
    }
}