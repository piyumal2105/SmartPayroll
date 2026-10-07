package com.smartpayroll.dao;

import com.smartpayroll.model.Leave;
import com.smartpayroll.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;

public class LeaveDAO {
    
    // Apply for leave
    public boolean applyLeave(Leave leave) {
        String query = "INSERT INTO leaves (staff_id, leave_type, start_date, end_date, reason, status) " +
                      "VALUES (?, ?, ?, ?, ?, 'PENDING')";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, leave.getStaffId());
            stmt.setString(2, leave.getLeaveType());
            stmt.setDate(3, leave.getStartDate());
            stmt.setDate(4, leave.getEndDate());
            stmt.setString(5, leave.getReason());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error applying for leave: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Update leave (only if pending)
    public boolean updateLeave(Leave leave) {
        String query = "UPDATE leaves SET leave_type = ?, start_date = ?, end_date = ?, " +
                      "reason = ?, updated_at = CURRENT_TIMESTAMP " +
                      "WHERE leave_id = ? AND status = 'PENDING'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, leave.getLeaveType());
            stmt.setDate(2, leave.getStartDate());
            stmt.setDate(3, leave.getEndDate());
            stmt.setString(4, leave.getReason());
            stmt.setInt(5, leave.getLeaveId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating leave: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Delete leave (only if pending)
    public boolean deleteLeave(int leaveId) {
        String query = "DELETE FROM leaves WHERE leave_id = ? AND status = 'PENDING'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, leaveId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error deleting leave: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Approve or reject leave (Admin only)
    public boolean updateLeaveStatus(int leaveId, String status, int approvedBy, String remarks) {
        String query = "UPDATE leaves SET status = ?, approved_by = ?, approved_date = CURDATE(), " +
                      "remarks = ?, updated_at = CURRENT_TIMESTAMP WHERE leave_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, approvedBy);
            stmt.setString(3, remarks);
            stmt.setInt(4, leaveId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating leave status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Get all leaves for a staff member
    public List<Leave> getLeavesByStaffId(int staffId) {
        List<Leave> leaves = new ArrayList<>();
        String query = "SELECT * FROM leaves WHERE staff_id = ? ORDER BY created_at DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, staffId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                leaves.add(extractLeaveFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return leaves;
    }
    
    // Get all leaves (for admin)
    public List<Leave> getAllLeaves() {
        List<Leave> leaves = new ArrayList<>();
        String query = "SELECT l.*, s.name as staff_name, s.email as staff_email " +
                      "FROM leaves l " +
                      "JOIN staff s ON l.staff_id = s.staff_id " +
                      "ORDER BY l.leave_id ASC";  // Changed from created_at DESC to leave_id ASC
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Leave leave = extractLeaveFromResultSet(rs);
                leave.setStaffName(rs.getString("staff_name"));
                leave.setStaffEmail(rs.getString("staff_email"));
                leaves.add(leave);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return leaves;
    }
    
    // Get pending leaves (for admin)
    public List<Leave> getPendingLeaves() {
        List<Leave> leaves = new ArrayList<>();
        String query = "SELECT l.*, s.name as staff_name, s.email as staff_email " +
                      "FROM leaves l " +
                      "JOIN staff s ON l.staff_id = s.staff_id " +
                      "WHERE l.status = 'PENDING' " +
                      "ORDER BY l.created_at ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Leave leave = extractLeaveFromResultSet(rs);
                leave.setStaffName(rs.getString("staff_name"));
                leave.setStaffEmail(rs.getString("staff_email"));
                leaves.add(leave);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return leaves;
    }
    
    // Get leave by ID
    public Leave getLeaveById(int leaveId) {
        String query = "SELECT l.*, s.name as staff_name, s.email as staff_email " +
                      "FROM leaves l " +
                      "JOIN staff s ON l.staff_id = s.staff_id " +
                      "WHERE l.leave_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, leaveId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Leave leave = extractLeaveFromResultSet(rs);
                leave.setStaffName(rs.getString("staff_name"));
                leave.setStaffEmail(rs.getString("staff_email"));
                return leave;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get approved leaves for a date range
    public List<Leave> getApprovedLeavesByDateRange(Date startDate, Date endDate) {
        List<Leave> leaves = new ArrayList<>();
        String query = "SELECT l.*, s.name as staff_name, s.email as staff_email " +
                      "FROM leaves l " +
                      "JOIN staff s ON l.staff_id = s.staff_id " +
                      "WHERE l.status = 'APPROVED' " +
                      "AND l.start_date <= ? AND l.end_date >= ? " +
                      "ORDER BY l.start_date ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setDate(1, endDate);
            stmt.setDate(2, startDate);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Leave leave = extractLeaveFromResultSet(rs);
                leave.setStaffName(rs.getString("staff_name"));
                leave.setStaffEmail(rs.getString("staff_email"));
                leaves.add(leave);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return leaves;
    }
    
    // Check if leave dates overlap with existing approved leaves
    public boolean hasOverlappingLeave(int staffId, Date startDate, Date endDate, Integer excludeLeaveId) {
        String query = "SELECT COUNT(*) FROM leaves " +
                      "WHERE staff_id = ? AND status = 'APPROVED' " +
                      "AND ((start_date <= ? AND end_date >= ?) OR " +
                      "     (start_date <= ? AND end_date >= ?) OR " +
                      "     (start_date >= ? AND end_date <= ?))";
        
        if (excludeLeaveId != null) {
            query += " AND leave_id != ?";
        }
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, staffId);
            stmt.setDate(2, endDate);
            stmt.setDate(3, startDate);
            stmt.setDate(4, startDate);
            stmt.setDate(5, startDate);
            stmt.setDate(6, startDate);
            stmt.setDate(7, endDate);
            
            if (excludeLeaveId != null) {
                stmt.setInt(8, excludeLeaveId);
            }
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Helper method to extract Leave from ResultSet
    private Leave extractLeaveFromResultSet(ResultSet rs) throws SQLException {
        Leave leave = new Leave();
        leave.setLeaveId(rs.getInt("leave_id"));
        leave.setStaffId(rs.getInt("staff_id"));
        leave.setLeaveType(rs.getString("leave_type"));
        leave.setStartDate(rs.getDate("start_date"));
        leave.setEndDate(rs.getDate("end_date"));
        leave.setReason(rs.getString("reason"));
        leave.setStatus(rs.getString("status"));
        leave.setApprovedBy(rs.getObject("approved_by", Integer.class));
        leave.setApprovedDate(rs.getDate("approved_date"));
        leave.setRemarks(rs.getString("remarks"));
        leave.setCreatedAt(rs.getTimestamp("created_at"));
        leave.setUpdatedAt(rs.getTimestamp("updated_at"));
        return leave;
    }
}