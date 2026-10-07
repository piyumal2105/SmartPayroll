package com.smartpayroll.model;

import java.io.Serializable;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int userId;
    private String email;
    private String nic;
    private String password;
    private String role;
    private boolean isActive;
    
    // Default constructor
    public User() {}
    
    // Parameterized constructor
    public User(String email, String nic, String password, String role) {
        this.email = email;
        this.nic = nic;
        this.password = password;
        this.role = role;
        this.isActive = true;
    }
    
    // Getters and Setters
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
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
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }
    
    @Override
    public String toString() {
        return "User [userId=" + userId + ", email=" + email + ", role=" + role + "]";
    }
}