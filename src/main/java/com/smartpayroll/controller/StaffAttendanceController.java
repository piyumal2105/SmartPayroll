package com.smartpayroll.controller;

import com.smartpayroll.dao.AttendanceDAO;
import com.smartpayroll.model.Attendance;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@WebServlet("/staff/attendance")
public class StaffAttendanceController extends HttpServlet {
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
        
        // Check if user is logged in and is staff
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute("userRole");
        if (!"STAFF".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        Integer staffId = (Integer) session.getAttribute("staffId");
        if (staffId == null) {
            request.setAttribute("error", "Staff ID not found in session.");
            request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
            return;
        }
        
        // Get today's date
        Date today = Date.valueOf(LocalDate.now());
        
        // Check if attendance already marked
        Attendance todayAttendance = attendanceDAO.getTodayAttendance(staffId, today);
        request.setAttribute("todayAttendance", todayAttendance);
        
        // Get attendance history
        List<Attendance> attendanceHistory = attendanceDAO.getAttendanceByStaffId(staffId);
        request.setAttribute("attendanceHistory", attendanceHistory);
        
        request.getRequestDispatcher("/views/staff/attendance.jsp").forward(request, response);
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
        if (!"STAFF".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        Integer staffId = (Integer) session.getAttribute("staffId");
        if (staffId == null) {
            request.setAttribute("error", "Staff ID not found.");
            doGet(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("checkin".equals(action)) {
            markCheckIn(request, response, staffId);
        } else if ("checkout".equals(action)) {
            markCheckOut(request, response, staffId);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/attendance");
        }
    }
    
    private void markCheckIn(HttpServletRequest request, HttpServletResponse response, int staffId) 
            throws ServletException, IOException {
        
        Date today = Date.valueOf(LocalDate.now());
        
        // Check if already marked
        if (attendanceDAO.isAttendanceMarked(staffId, today)) {
            request.setAttribute("error", "Attendance already marked for today.");
            doGet(request, response);
            return;
        }
        
        Time checkInTime = Time.valueOf(LocalTime.now());
        String notes = request.getParameter("notes");
        
        // Determine status based on check-in time (e.g., late if after 9:00 AM)
        LocalTime standardTime = LocalTime.of(9, 0);
        String status = checkInTime.toLocalTime().isAfter(standardTime) ? "LATE" : "PRESENT";
        
        Attendance attendance = new Attendance();
        attendance.setStaffId(staffId);
        attendance.setAttendanceDate(today);
        attendance.setCheckInTime(checkInTime);
        attendance.setStatus(status);
        attendance.setNotes(notes != null ? notes.trim() : "");
        
        boolean success = attendanceDAO.markAttendance(attendance);
        
        if (success) {
            request.setAttribute("success", "Attendance marked successfully! Check-in time: " + checkInTime);
        } else {
            request.setAttribute("error", "Failed to mark attendance. Please try again.");
        }
        
        doGet(request, response);
    }
    
    private void markCheckOut(HttpServletRequest request, HttpServletResponse response, int staffId) 
            throws ServletException, IOException {
        
        Date today = Date.valueOf(LocalDate.now());
        
        // Check if check-in exists
        Attendance todayAttendance = attendanceDAO.getTodayAttendance(staffId, today);
        if (todayAttendance == null) {
            request.setAttribute("error", "Please mark check-in first.");
            doGet(request, response);
            return;
        }
        
        if (todayAttendance.getCheckOutTime() != null) {
            request.setAttribute("error", "Check-out already marked for today.");
            doGet(request, response);
            return;
        }
        
        Time checkOutTime = Time.valueOf(LocalTime.now());
        
        boolean success = attendanceDAO.updateCheckOut(staffId, today, checkOutTime);
        
        if (success) {
            request.setAttribute("success", "Check-out marked successfully! Check-out time: " + checkOutTime);
        } else {
            request.setAttribute("error", "Failed to mark check-out. Please try again.");
        }
        
        doGet(request, response);
    }
}