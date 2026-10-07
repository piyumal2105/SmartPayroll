package com.smartpayroll.dao;

import com.smartpayroll.model.LeaveBalance;
import com.smartpayroll.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;

public class LeaveBalanceDAO {
    
    // Initialize leave balance for a staff member
    public boolean initializeLeaveBalance(int staffId, int year) {
        String query = "INSERT INTO leave_balance (staff_id, year, sick_leave, casual_leave, annual_leave) " +
                      "VALUES (?, ?, 7, 7, 14) " +
                      "ON DUPLICATE KEY UPDATE staff_id=staff_id"; // Do nothing if exists
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, staffId);
            stmt.setInt(2, year);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error initializing leave balance: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Get leave balance for a staff member
    public LeaveBalance getLeaveBalance(int staffId, int year) {
        String query = "SELECT * FROM leave_balance WHERE staff_id = ? AND year = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, staffId);
            stmt.setInt(2, year);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractLeaveBalanceFromResultSet(rs);
            } else {
                // If no balance exists, create one
                initializeLeaveBalance(staffId, year);
                return getLeaveBalance(staffId, year);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Update leave balance
    public boolean updateLeaveBalance(LeaveBalance balance) {
        String query = "UPDATE leave_balance SET sick_leave = ?, casual_leave = ?, " +
                      "annual_leave = ?, updated_at = CURRENT_TIMESTAMP " +
                      "WHERE balance_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, balance.getSickLeave());
            stmt.setInt(2, balance.getCasualLeave());
            stmt.setInt(3, balance.getAnnualLeave());
            stmt.setInt(4, balance.getBalanceId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating leave balance: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Deduct leave balance
    public boolean deductLeaveBalance(int staffId, int year, String leaveType, int days) {
        LeaveBalance balance = getLeaveBalance(staffId, year);
        if (balance == null) {
            return false;
        }
        
        switch (leaveType) {
            case "SICK":
                balance.setSickLeave(Math.max(0, balance.getSickLeave() - days));
                break;
            case "CASUAL":
                balance.setCasualLeave(Math.max(0, balance.getCasualLeave() - days));
                break;
            case "ANNUAL":
                balance.setAnnualLeave(Math.max(0, balance.getAnnualLeave() - days));
                break;
            default:
                return true; // For EMERGENCY or OTHER, don't deduct
        }
        
        return updateLeaveBalance(balance);
    }
    
    // Check if staff has sufficient leave balance
    public boolean hasSufficientBalance(int staffId, int year, String leaveType, int days) {
        LeaveBalance balance = getLeaveBalance(staffId, year);
        if (balance == null) {
            return false;
        }
        
        switch (leaveType) {
            case "SICK":
                return balance.getSickLeave() >= days;
            case "CASUAL":
                return balance.getCasualLeave() >= days;
            case "ANNUAL":
                return balance.getAnnualLeave() >= days;
            default:
                return true; // EMERGENCY or OTHER don't require balance
        }
    }
    
    // Get all leave balances (for admin)
    public List<LeaveBalance> getAllLeaveBalances(int year) {
        List<LeaveBalance> balances = new ArrayList<>();
        String query = "SELECT lb.*, s.name as staff_name " +
                      "FROM leave_balance lb " +
                      "JOIN staff s ON lb.staff_id = s.staff_id " +
                      "WHERE lb.year = ? " +
                      "ORDER BY s.name ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, year);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                LeaveBalance balance = extractLeaveBalanceFromResultSet(rs);
                balance.setStaffName(rs.getString("staff_name"));
                balances.add(balance);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return balances;
    }
    
    // Helper method
    private LeaveBalance extractLeaveBalanceFromResultSet(ResultSet rs) throws SQLException {
        LeaveBalance balance = new LeaveBalance();
        balance.setBalanceId(rs.getInt("balance_id"));
        balance.setStaffId(rs.getInt("staff_id"));
        balance.setYear(rs.getInt("year"));
        balance.setSickLeave(rs.getInt("sick_leave"));
        balance.setCasualLeave(rs.getInt("casual_leave"));
        balance.setAnnualLeave(rs.getInt("annual_leave"));
        balance.setCreatedAt(rs.getTimestamp("created_at"));
        balance.setUpdatedAt(rs.getTimestamp("updated_at"));
        return balance;
    }
}