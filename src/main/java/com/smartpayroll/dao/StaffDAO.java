package com.smartpayroll.dao;

import com.smartpayroll.model.Staff;
import com.smartpayroll.model.User;
import com.smartpayroll.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDAO {
    
    // Add new staff member (Admin only)
	public boolean addStaff(Staff staff) {
	    String userQuery = "INSERT INTO users (email, nic, role) VALUES (?, ?, 'STAFF')";
	    String staffQuery = "INSERT INTO staff (name, email, nic, phone, role, salary, join_date) VALUES (?, ?, ?, ?, ?, ?, CURDATE())";
	    
	    Connection conn = null;
	    try {
	        conn = DatabaseConnection.getConnection();
	        conn.setAutoCommit(false); // Start transaction
	        
	        // Insert into USERS table FIRST ✅
	        try (PreparedStatement stmt = conn.prepareStatement(userQuery)) {
	            stmt.setString(1, staff.getEmail());
	            stmt.setString(2, staff.getNic());
	            stmt.executeUpdate();
	        }
	        
	        // Insert into STAFF table SECOND ✅
	        try (PreparedStatement stmt = conn.prepareStatement(staffQuery)) {
	            stmt.setString(1, staff.getName());
	            stmt.setString(2, staff.getEmail());
	            stmt.setString(3, staff.getNic());
	            stmt.setString(4, staff.getPhone());
	            stmt.setString(5, staff.getRole());
	            stmt.setDouble(6, staff.getSalary());
	            stmt.executeUpdate();
	        }
	        
	        conn.commit(); // Commit transaction
	        return true;
	        
	    } catch (SQLException e) {
	        if (conn != null) {
	            try {
	                conn.rollback(); // Rollback on error
	            } catch (SQLException ex) {
	                ex.printStackTrace();
	            }
	        }
	        System.err.println("Error adding staff: " + e.getMessage());
	        e.printStackTrace();
	        return false;
	    } finally {
	        if (conn != null) {
	            try {
	                conn.setAutoCommit(true);
	            } catch (SQLException e) {
	                e.printStackTrace();
	            }
	        }
	    }
	}
    // Get staff by ID
    public Staff getStaffById(int staffId) {
        String query = "SELECT * FROM staff WHERE staff_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, staffId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Staff staff = new Staff();
                staff.setStaffId(rs.getInt("staff_id"));
                staff.setName(rs.getString("name"));
                staff.setEmail(rs.getString("email"));
                staff.setNic(rs.getString("nic"));
                staff.setPhone(rs.getString("phone"));
                staff.setRole(rs.getString("role"));
                staff.setSalary(rs.getDouble("salary"));
                staff.setJoinDate(rs.getDate("join_date"));
                staff.setActive(rs.getBoolean("is_active"));
                return staff;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get staff by email
    public Staff getStaffByEmail(String email) {
        String query = "SELECT * FROM staff WHERE email = ? AND is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Staff staff = new Staff();
                staff.setStaffId(rs.getInt("staff_id"));
                staff.setName(rs.getString("name"));
                staff.setEmail(rs.getString("email"));
                staff.setNic(rs.getString("nic"));
                staff.setPhone(rs.getString("phone"));
                staff.setRole(rs.getString("role"));
                staff.setSalary(rs.getDouble("salary"));
                staff.setJoinDate(rs.getDate("join_date"));
                staff.setActive(rs.getBoolean("is_active"));
                return staff;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get all staff
    public List<Staff> getAllStaff() {
        List<Staff> staffList = new ArrayList<>();
        String query = "SELECT * FROM staff ORDER BY staff_id ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Staff staff = new Staff();
                staff.setStaffId(rs.getInt("staff_id"));
                staff.setName(rs.getString("name"));
                staff.setEmail(rs.getString("email"));
                staff.setNic(rs.getString("nic"));
                staff.setPhone(rs.getString("phone"));
                staff.setRole(rs.getString("role"));
                staff.setSalary(rs.getDouble("salary"));
                staff.setJoinDate(rs.getDate("join_date"));
                staff.setActive(rs.getBoolean("is_active"));
                staffList.add(staff);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staffList;
    }
    
    // Update staff
    public boolean updateStaff(Staff staff) {
        String query = "UPDATE staff SET name = ?, email = ?, nic = ?, phone = ?, role = ?, salary = ? WHERE staff_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, staff.getName());
            stmt.setString(2, staff.getEmail());
            stmt.setString(3, staff.getNic());
            stmt.setString(4, staff.getPhone());
            stmt.setString(5, staff.getRole());
            stmt.setDouble(6, staff.getSalary());
            stmt.setInt(7, staff.getStaffId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating staff: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Delete staff (set inactive)
 // Delete staff permanently (removes from both tables)
    public boolean deleteStaff(int staffId) {
        String getEmailQuery = "SELECT email FROM staff WHERE staff_id = ?";
        String deleteStaffQuery = "DELETE FROM staff WHERE staff_id = ?";
        String deleteUserQuery = "DELETE FROM users WHERE email = ? AND role = 'STAFF'";
        
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // First, get the email associated with this staff member
            String email = null;
            try (PreparedStatement stmt = conn.prepareStatement(getEmailQuery)) {
                stmt.setInt(1, staffId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    email = rs.getString("email");
                }
            }
            
            if (email == null) {
                return false; // Staff member not found
            }
            
            // Delete from staff table first (child table)
            try (PreparedStatement stmt = conn.prepareStatement(deleteStaffQuery)) {
                stmt.setInt(1, staffId);
                stmt.executeUpdate();
            }
            
            // Delete from users table (parent table)
            try (PreparedStatement stmt = conn.prepareStatement(deleteUserQuery)) {
                stmt.setString(1, email);
                stmt.executeUpdate();
            }
            
            conn.commit(); // Commit transaction
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            System.err.println("Error deleting staff: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    // Check if email already exists
    public boolean emailExists(String email) {
        String query = "SELECT COUNT(*) FROM staff WHERE email = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Check if NIC already exists
    public boolean nicExists(String nic) {
        String query = "SELECT COUNT(*) FROM staff WHERE nic = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, nic);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}