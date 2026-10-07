package com.smartpayroll.dao;

import com.smartpayroll.model.Payroll;
import com.smartpayroll.util.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class PayrollDAO {

    // Create payroll record
    public boolean addPayroll(Payroll payroll) {
        String sql = "INSERT INTO payroll (staff_id, month, year, basic_salary, bonus, " +
                     "deductions, net_salary, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, payroll.getStaffId());
            pstmt.setString(2, payroll.getMonth());
            pstmt.setInt(3, payroll.getYear());
            pstmt.setBigDecimal(4, payroll.getBasicSalary());
            pstmt.setBigDecimal(5, payroll.getBonus());
            pstmt.setBigDecimal(6, payroll.getDeductions());
            pstmt.setBigDecimal(7, payroll.getNetSalary());
            pstmt.setString(8, payroll.getStatus());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all payroll records with staff details
    public List<Payroll> getAllPayrolls() {
        List<Payroll> payrolls = new ArrayList<>();
        String sql = "SELECT p.*, s.name as staff_name, s.email as staff_email " +
                "FROM payroll p " +
                "JOIN staff s ON p.staff_id = s.staff_id " +
                "ORDER BY p.payroll_id ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                payrolls.add(extractPayrollFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return payrolls;
    }

    // Get payroll by ID
    public Payroll getPayrollById(int payrollId) {
        String sql = "SELECT p.*, s.name as staff_name, s.email as staff_email " +
                     "FROM payroll p " +
                     "JOIN staff s ON p.staff_id = s.staff_id " +
                     "WHERE p.payroll_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, payrollId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractPayrollFromResultSet(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    // Get payroll records for specific staff
    public List<Payroll> getPayrollsByStaffId(int staffId) {
        List<Payroll> payrolls = new ArrayList<>();
        String sql = "SELECT p.*, s.name as staff_name, s.email as staff_email " +
                     "FROM payroll p " +
                     "JOIN staff s ON p.staff_id = s.staff_id " +
                     "WHERE p.staff_id = ? " +
                     "ORDER BY p.year DESC, p.month DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, staffId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                payrolls.add(extractPayrollFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return payrolls;
    }

    // Filter payrolls by month, year, or status
    public List<Payroll> filterPayrolls(String month, Integer year, String status) {
        List<Payroll> payrolls = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, s.name as staff_name, s.email as staff_email " +
            "FROM payroll p JOIN staff s ON p.staff_id = s.staff_id WHERE 1=1"
        );
        
        if (month != null && !month.isEmpty()) {
            sql.append(" AND p.month = ?");
        }
        if (year != null) {
            sql.append(" AND p.year = ?");
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND p.status = ?");
        }
        
        sql.append(" ORDER BY p.payroll_id ASC");  // Changed here
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (month != null && !month.isEmpty()) {
                pstmt.setString(paramIndex++, month);
            }
            if (year != null) {
                pstmt.setInt(paramIndex++, year);
            }
            if (status != null && !status.isEmpty()) {
                pstmt.setString(paramIndex++, status);
            }
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                payrolls.add(extractPayrollFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return payrolls;
    }

    // Update payroll
    public boolean updatePayroll(Payroll payroll) {
        String sql = "UPDATE payroll SET basic_salary = ?, bonus = ?, deductions = ?, " +
                     "net_salary = ?, status = ? WHERE payroll_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setBigDecimal(1, payroll.getBasicSalary());
            pstmt.setBigDecimal(2, payroll.getBonus());
            pstmt.setBigDecimal(3, payroll.getDeductions());
            pstmt.setBigDecimal(4, payroll.getNetSalary());
            pstmt.setString(5, payroll.getStatus());
            pstmt.setInt(6, payroll.getPayrollId());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Process payroll (mark as PROCESSED)
    public boolean processPayroll(int payrollId) {
        String sql = "UPDATE payroll SET status = 'PROCESSED', processed_at = NOW() " +
                     "WHERE payroll_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, payrollId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete payroll
    public boolean deletePayroll(int payrollId) {
        String sql = "DELETE FROM payroll WHERE payroll_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, payrollId);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Check if payroll already exists for staff in specific month/year
    public boolean payrollExists(int staffId, String month, int year, Integer excludePayrollId) {
        String sql = "SELECT COUNT(*) FROM payroll WHERE staff_id = ? AND month = ? AND year = ?";
        
        if (excludePayrollId != null) {
            sql += " AND payroll_id != ?";
        }
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, staffId);
            pstmt.setString(2, month);
            pstmt.setInt(3, year);
            
            if (excludePayrollId != null) {
                pstmt.setInt(4, excludePayrollId);
            }
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }

    // Helper method to extract Payroll from ResultSet
    private Payroll extractPayrollFromResultSet(ResultSet rs) throws SQLException {
        Payroll payroll = new Payroll();
        payroll.setPayrollId(rs.getInt("payroll_id"));
        payroll.setStaffId(rs.getInt("staff_id"));
        payroll.setStaffName(rs.getString("staff_name"));
        payroll.setStaffEmail(rs.getString("staff_email"));
        payroll.setMonth(rs.getString("month"));
        payroll.setYear(rs.getInt("year"));
        payroll.setBasicSalary(rs.getBigDecimal("basic_salary"));
        payroll.setBonus(rs.getBigDecimal("bonus"));
        payroll.setDeductions(rs.getBigDecimal("deductions"));
        payroll.setNetSalary(rs.getBigDecimal("net_salary"));
        payroll.setStatus(rs.getString("status"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            payroll.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp processedAt = rs.getTimestamp("processed_at");
        if (processedAt != null) {
            payroll.setProcessedAt(processedAt.toLocalDateTime());
        }
        
        return payroll;
    }
}