package com.smartpayroll.dao;

import com.smartpayroll.model.User;
import com.smartpayroll.util.DatabaseConnection;
import java.sql.*;

public class UserDAO {
    
    // Authenticate user
    public User authenticate(String email, String nic, String password) {
        String query = "SELECT * FROM users WHERE email = ? AND nic = ? AND password = MD5(?) AND is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            stmt.setString(2, nic);
            stmt.setString(3, password);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setNic(rs.getString("nic"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Authentication error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    // Get user by ID
    public User getUserById(int userId) {
        String query = "SELECT * FROM users WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setNic(rs.getString("nic"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Create new staff user (for admin)
    public boolean createStaffUser(String email, String nic, String password) {
        String query = "INSERT INTO users (email, nic, password, role) VALUES (?, ?, MD5(?), 'STAFF')";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            stmt.setString(2, nic);
            stmt.setString(3, password);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error creating user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Check if email already exists
    public boolean emailExists(String email) {
        String query = "SELECT COUNT(*) FROM users WHERE email = ?";
        
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
        String query = "SELECT COUNT(*) FROM users WHERE nic = ?";
        
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

    /**
     * Authenticate admin user with email and password only
     */
    public User authenticateAdmin(String email, String password) {
        String query = "SELECT * FROM users WHERE email = ? AND password = MD5(?) AND role = 'ADMIN' AND is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            stmt.setString(2, password);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setNic(rs.getString("nic"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Admin authentication error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Authenticate staff user with email and NIC only (no password)
     */
    public User authenticateStaff(String email, String nic) {
        String query = "SELECT * FROM users WHERE email = ? AND nic = ? AND role = 'STAFF' AND is_active = TRUE";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            stmt.setString(2, nic);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setNic(rs.getString("nic"));
                user.setRole(rs.getString("role"));
                user.setActive(rs.getBoolean("is_active"));
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Staff authentication error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}