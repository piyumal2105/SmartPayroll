package com.smartpayroll.dao;

import com.smartpayroll.model.Attendance;
import com.smartpayroll.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AttendanceDAO {
    
    // Mark attendance (Check In)
    public boolean markAttendance(Attendance attendance) {
        String query = "INSERT INTO attendance (staff_id, attendance_date, check_in_time, status, notes) " +
                      "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, attendance.getStaffId());
            stmt.setDate(2, attendance.getAttendanceDate());
            stmt.setTime(3, attendance.getCheckInTime());
            stmt.setString(4, attendance.getStatus());
            stmt.setString(5, attendance.getNotes());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error marking attendance: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Update check-out time
    public boolean updateCheckOut(int staffId, Date attendanceDate, Time checkOutTime) {
        String query = "UPDATE attendance SET check_out_time = ?, updated_at = CURRENT_TIMESTAMP " +
                      "WHERE staff_id = ? AND attendance_date = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setTime(1, checkOutTime);
            stmt.setInt(2, staffId);
            stmt.setDate(3, attendanceDate);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating check-out: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Update attendance record
    public boolean updateAttendance(Attendance attendance) {
        String query = "UPDATE attendance SET check_in_time = ?, check_out_time = ?, " +
                      "status = ?, notes = ?, updated_at = CURRENT_TIMESTAMP " +
                      "WHERE attendance_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setTime(1, attendance.getCheckInTime());
            stmt.setTime(2, attendance.getCheckOutTime());
            stmt.setString(3, attendance.getStatus());
            stmt.setString(4, attendance.getNotes());
            stmt.setInt(5, attendance.getAttendanceId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating attendance: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Delete attendance record
    public boolean deleteAttendance(int attendanceId) {
        String query = "DELETE FROM attendance WHERE attendance_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, attendanceId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error deleting attendance: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Check if attendance already marked for today
    public boolean isAttendanceMarked(int staffId, Date date) {
        String query = "SELECT COUNT(*) FROM attendance WHERE staff_id = ? AND attendance_date = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, staffId);
            stmt.setDate(2, date);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get today's attendance for a staff member
    public Attendance getTodayAttendance(int staffId, Date date) {
        String query = "SELECT * FROM attendance WHERE staff_id = ? AND attendance_date = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, staffId);
            stmt.setDate(2, date);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return extractAttendanceFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get attendance by staff ID
    public List<Attendance> getAttendanceByStaffId(int staffId) {
        List<Attendance> attendanceList = new ArrayList<>();
        String query = "SELECT * FROM attendance WHERE staff_id = ? ORDER BY attendance_id ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, staffId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                attendanceList.add(extractAttendanceFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attendanceList;
    }
    
    // Get all attendance records with staff info (for admin)
    public List<Attendance> getAllAttendance() {
        List<Attendance> attendanceList = new ArrayList<>();
        String query = "SELECT a.*, s.name as staff_name, s.email as staff_email " +
                      "FROM attendance a " +
                      "JOIN staff s ON a.staff_id = s.staff_id " +
                      "ORDER BY a.attendance_id ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Attendance attendance = extractAttendanceFromResultSet(rs);
                attendance.setStaffName(rs.getString("staff_name"));
                attendance.setStaffEmail(rs.getString("staff_email"));
                attendanceList.add(attendance);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attendanceList;
    }
    
    // Get attendance by date
    public List<Attendance> getAttendanceByDate(Date date) {
        List<Attendance> attendanceList = new ArrayList<>();
        String query = "SELECT a.*, s.name as staff_name, s.email as staff_email " +
                      "FROM attendance a " +
                      "JOIN staff s ON a.staff_id = s.staff_id " +
                      "WHERE a.attendance_date = ? " +
                      "ORDER BY s.name ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setDate(1, date);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Attendance attendance = extractAttendanceFromResultSet(rs);
                attendance.setStaffName(rs.getString("staff_name"));
                attendance.setStaffEmail(rs.getString("staff_email"));
                attendanceList.add(attendance);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attendanceList;
    }
    
    // Get attendance by date range
    public List<Attendance> getAttendanceByDateRange(Date startDate, Date endDate) {
        List<Attendance> attendanceList = new ArrayList<>();
        String query = "SELECT a.*, s.name as staff_name, s.email as staff_email " +
                      "FROM attendance a " +
                      "JOIN staff s ON a.staff_id = s.staff_id " +
                      "WHERE a.attendance_date BETWEEN ? AND ? " +
                      "ORDER BY a.attendance_date ASC, s.name ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setDate(1, startDate);
            stmt.setDate(2, endDate);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Attendance attendance = extractAttendanceFromResultSet(rs);
                attendance.setStaffName(rs.getString("staff_name"));
                attendance.setStaffEmail(rs.getString("staff_email"));
                attendanceList.add(attendance);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attendanceList;
    }
    
    // Get attendance by ID
    public Attendance getAttendanceById(int attendanceId) {
        String query = "SELECT a.*, s.name as staff_name, s.email as staff_email " +
                      "FROM attendance a " +
                      "JOIN staff s ON a.staff_id = s.staff_id " +
                      "WHERE a.attendance_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, attendanceId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Attendance attendance = extractAttendanceFromResultSet(rs);
                attendance.setStaffName(rs.getString("staff_name"));
                attendance.setStaffEmail(rs.getString("staff_email"));
                return attendance;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Helper method to extract Attendance from ResultSet
    private Attendance extractAttendanceFromResultSet(ResultSet rs) throws SQLException {
        Attendance attendance = new Attendance();
        attendance.setAttendanceId(rs.getInt("attendance_id"));
        attendance.setStaffId(rs.getInt("staff_id"));
        attendance.setAttendanceDate(rs.getDate("attendance_date"));
        attendance.setCheckInTime(rs.getTime("check_in_time"));
        attendance.setCheckOutTime(rs.getTime("check_out_time"));
        attendance.setStatus(rs.getString("status"));
        attendance.setNotes(rs.getString("notes"));
        attendance.setCreatedAt(rs.getTimestamp("created_at"));
        attendance.setUpdatedAt(rs.getTimestamp("updated_at"));
        return attendance;
    }
    
    // Get attendance statistics for a staff member
    public int getTotalPresentDays(int staffId, Date startDate, Date endDate) {
        String query = "SELECT COUNT(*) FROM attendance " +
                      "WHERE staff_id = ? AND attendance_date BETWEEN ? AND ? " +
                      "AND status = 'PRESENT'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, staffId);
            stmt.setDate(2, startDate);
            stmt.setDate(3, endDate);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}