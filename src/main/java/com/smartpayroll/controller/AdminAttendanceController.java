package com.smartpayroll.controller;

import com.smartpayroll.dao.AttendanceDAO;
import com.smartpayroll.model.Attendance;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.List;

@WebServlet("/admin/attendance")
public class AdminAttendanceController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AttendanceDAO attendanceDAO;
    
    @Override
    public void init() {
        attendanceDAO = new AttendanceDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in and is admin
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute("userRole");
        if (!"ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String filterDate = request.getParameter("filterDate");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        
        List<Attendance> attendanceList;
        
        if (filterDate != null && !filterDate.trim().isEmpty()) {
            // Filter by specific date
            attendanceList = attendanceDAO.getAttendanceByDate(Date.valueOf(filterDate));
        } else if (startDate != null && endDate != null && 
                   !startDate.trim().isEmpty() && !endDate.trim().isEmpty()) {
            // Filter by date range
            attendanceList = attendanceDAO.getAttendanceByDateRange(
                Date.valueOf(startDate), Date.valueOf(endDate));
        } else {
            // Get all attendance
            attendanceList = attendanceDAO.getAllAttendance();
        }
        
        request.setAttribute("attendanceList", attendanceList);
        request.setAttribute("filterDate", filterDate);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        
        request.getRequestDispatcher("/views/admin/attendance.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check authentication
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute("userRole");
        if (!"ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("update".equals(action)) {
            updateAttendance(request, response);
        } else if ("delete".equals(action)) {
            deleteAttendance(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/attendance");
        }
    }
    
    private void updateAttendance(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String attendanceIdStr = request.getParameter("attendanceId");
        String checkInTimeStr = request.getParameter("checkInTime");
        String checkOutTimeStr = request.getParameter("checkOutTime");
        String status = request.getParameter("status");
        String notes = request.getParameter("notes");
        
        try {
            int attendanceId = Integer.parseInt(attendanceIdStr);
            
            // First, get the existing attendance record to preserve other fields
            Attendance existingAttendance = attendanceDAO.getAttendanceById(attendanceId);
            
            if (existingAttendance == null) {
                request.setAttribute("error", "Attendance record not found.");
                doGet(request, response);
                return;
            }
            
            // Update only the fields that are being modified
            existingAttendance.setAttendanceId(attendanceId);
            
            // Update check-in time
            if (checkInTimeStr != null && !checkInTimeStr.trim().isEmpty()) {
                existingAttendance.setCheckInTime(Time.valueOf(checkInTimeStr + ":00"));
            }
            
            // Update check-out time (can be null)
            if (checkOutTimeStr != null && !checkOutTimeStr.trim().isEmpty()) {
                existingAttendance.setCheckOutTime(Time.valueOf(checkOutTimeStr + ":00"));
            } else {
                existingAttendance.setCheckOutTime(null);
            }
            
            existingAttendance.setStatus(status);
            existingAttendance.setNotes(notes != null ? notes.trim() : "");
            
            boolean success = attendanceDAO.updateAttendance(existingAttendance);
            
            if (success) {
                request.setAttribute("success", "Attendance updated successfully!");
            } else {
                request.setAttribute("error", "Failed to update attendance.");
            }
            
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid time format. Please use HH:MM format (e.g., 09:30).");
        } catch (Exception e) {
            request.setAttribute("error", "Error updating attendance: " + e.getMessage());
            e.printStackTrace();
        }
        
        doGet(request, response);
    }
    
    private void deleteAttendance(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String attendanceIdStr = request.getParameter("attendanceId");
        
        try {
            int attendanceId = Integer.parseInt(attendanceIdStr);
            boolean success = attendanceDAO.deleteAttendance(attendanceId);
            
            if (success) {
                request.setAttribute("success", "Attendance record deleted successfully!");
            } else {
                request.setAttribute("error", "Failed to delete attendance record.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid attendance ID.");
        }
        
        doGet(request, response);
    }
}