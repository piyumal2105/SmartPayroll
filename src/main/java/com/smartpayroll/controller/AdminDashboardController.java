package com.smartpayroll.controller;

import com.smartpayroll.dao.StaffDAO;
import com.smartpayroll.dao.AttendanceDAO;
import com.smartpayroll.dao.LeaveDAO;
import com.smartpayroll.dao.PayrollDAO;
import com.smartpayroll.model.Staff;
import com.smartpayroll.model.Leave;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/dashboard")
public class AdminDashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private StaffDAO staffDAO;
    private AttendanceDAO attendanceDAO;
    private LeaveDAO leaveDAO;
    private PayrollDAO payrollDAO;
    
    @Override
    public void init() {
        staffDAO = new StaffDAO();
        attendanceDAO = new AttendanceDAO();
        leaveDAO = new LeaveDAO();
        payrollDAO = new PayrollDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Check if user is admin
        String role = (String) session.getAttribute("userRole");
        if (!"ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Fetch dashboard statistics
        try {
            // 1. Total Staff Count
            int totalStaff = staffDAO.getAllStaff().size();
            
            // 2. Present Today Count
            Date today = Date.valueOf(LocalDate.now());
            int presentToday = attendanceDAO.getAttendanceByDate(today).stream()
                .filter(att -> "PRESENT".equals(att.getStatus()) || "LATE".equals(att.getStatus()))
                .toList()
                .size();
            
            // 3. Pending Leave Requests
            int pendingLeaveRequests = leaveDAO.getPendingLeaves().size();
            
            // 4. Processed Payroll This Month
            int currentYear = LocalDate.now().getYear();
            String monthName = LocalDate.now().getMonth().toString();
            
            int processedPayroll = payrollDAO.getAllPayrolls().stream()
                .filter(p -> p.getMonth().equalsIgnoreCase(monthName) && 
                           p.getYear() == currentYear &&
                           "PROCESSED".equals(p.getStatus()))
                .toList()
                .size();
            
            // Set attributes for JSP
            request.setAttribute("totalStaff", totalStaff);
            request.setAttribute("presentToday", presentToday);
            request.setAttribute("pendingLeaveRequests", pendingLeaveRequests);
            request.setAttribute("processedPayroll", processedPayroll);
            
            // 5. Recent Activity (last 5 actions)
            List<String> recentActivity = new ArrayList<>();
            
            // Get recent staff additions
            List<Staff> recentStaff = staffDAO.getAllStaff().stream()
                .sorted((s1, s2) -> {
                    if (s2.getJoinDate() != null && s1.getJoinDate() != null) {
                        return s2.getJoinDate().compareTo(s1.getJoinDate());
                    }
                    return 0;
                })
                .limit(2)
                .toList();
            
            for (Staff staff : recentStaff) {
                if (staff.getJoinDate() != null) {
                    recentActivity.add("New staff member added: " + staff.getName() + " on " + staff.getJoinDate());
                }
            }
            
            // Get recent leave approvals/rejections
            List<Leave> recentLeaves = leaveDAO.getAllLeaves().stream()
                .filter(l -> "APPROVED".equals(l.getStatus()) || "REJECTED".equals(l.getStatus()))
                .sorted((l1, l2) -> {
                    if (l2.getUpdatedAt() != null && l1.getUpdatedAt() != null) {
                        return l2.getUpdatedAt().compareTo(l1.getUpdatedAt());
                    }
                    return 0;
                })
                .limit(3)
                .toList();
            
            for (Leave leave : recentLeaves) {
                String activityMsg = "Leave request " + leave.getStatus().toLowerCase() + " for " + 
                                   (leave.getStaffName() != null ? leave.getStaffName() : "staff member");
                recentActivity.add(activityMsg);
            }
            
            request.setAttribute("recentActivity", recentActivity);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading dashboard data: " + e.getMessage());
        }
        
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }
}