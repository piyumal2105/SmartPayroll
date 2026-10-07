package com.smartpayroll.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class Attendance implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int attendanceId;
    private int staffId;
    private Date attendanceDate;
    private Time checkInTime;
    private Time checkOutTime;
    private String status; // PRESENT, ABSENT, LATE, HALF_DAY
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // For displaying with staff info
    private String staffName;
    private String staffEmail;
    
    // Default constructor
    public Attendance() {}
    
    // Parameterized constructor
    public Attendance(int staffId, Date attendanceDate, Time checkInTime, 
                     Time checkOutTime, String status, String notes) {
        this.staffId = staffId;
        this.attendanceDate = attendanceDate;
        this.checkInTime = checkInTime;
        this.checkOutTime = checkOutTime;
        this.status = status;
        this.notes = notes;
    }
    
    // Getters and Setters
    public int getAttendanceId() {
        return attendanceId;
    }
    
    public void setAttendanceId(int attendanceId) {
        this.attendanceId = attendanceId;
    }
    
    public int getStaffId() {
        return staffId;
    }
    
    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }
    
    public Date getAttendanceDate() {
        return attendanceDate;
    }
    
    public void setAttendanceDate(Date attendanceDate) {
        this.attendanceDate = attendanceDate;
    }
    
    public Time getCheckInTime() {
        return checkInTime;
    }
    
    public void setCheckInTime(Time checkInTime) {
        this.checkInTime = checkInTime;
    }
    
    public Time getCheckOutTime() {
        return checkOutTime;
    }
    
    public void setCheckOutTime(Time checkOutTime) {
        this.checkOutTime = checkOutTime;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
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
    
    @Override
    public String toString() {
        return "Attendance [attendanceId=" + attendanceId + ", staffId=" + staffId + 
               ", date=" + attendanceDate + ", status=" + status + "]";
    }
}