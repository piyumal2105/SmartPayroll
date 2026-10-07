package com.smartpayroll.model;

import java.io.Serializable;
import java.sql.Date;

public class Staff implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int staffId;
    private String name;
    private String email;
    private String nic;
    private String phone;
    private String role;
    private double salary;
    private Date joinDate;
    private boolean isActive;
    
    // Default constructor
    public Staff() {}
    
    // Parameterized constructor
    public Staff(String name, String email, String nic, String phone, String role, double salary) {
        this.name = name;
        this.email = email;
        this.nic = nic;
        this.phone = phone;
        this.role = role;
        this.salary = salary;
        this.isActive = true;
    }
    
    // Getters and Setters
    public int getStaffId() {
        return staffId;
    }
    
    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getNic() {
        return nic;
    }
    
    public void setNic(String nic) {
        this.nic = nic;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public double getSalary() {
        return salary;
    }
    
    public void setSalary(double salary) {
        this.salary = salary;
    }
    
    public Date getJoinDate() {
        return joinDate;
    }
    
    public void setJoinDate(Date joinDate) {
        this.joinDate = joinDate;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }
    
    @Override
    public String toString() {
        return "Staff [staffId=" + staffId + ", name=" + name + ", email=" + email + 
               ", nic=" + nic + ", role=" + role + "]";
    }
}