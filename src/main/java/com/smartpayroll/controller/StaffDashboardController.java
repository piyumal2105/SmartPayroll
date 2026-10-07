package com.smartpayroll.controller;

import com.smartpayroll.dao.*;
import com.smartpayroll.model.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

@WebServlet("/staff/dashboard")
public class StaffDashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private StaffDAO staffDAO;
    private AttendanceDAO attendanceDAO;
    private LeaveDAO leaveDAO;
    private LeaveBalanceDAO leaveBalanceDAO;
    private PayrollDAO payrollDAO;
    
    @Override
    public void init() {
        staffDAO = new StaffDAO();
        attendanceDAO = new AttendanceDAO();
        leaveDAO = new LeaveDAO();
        leaveBalanceDAO = new LeaveBalanceDAO();
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
        
        // Check if user is staff
        String role = (String) session.getAttribute("userRole");
        if (!"STAFF".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Get staff information
        User user = (User) session.getAttribute("user");
        Staff staff = staffDAO.getStaffByEmail(user.getEmail());
        
        if (staff == null) {
            request.setAttribute("error", "Staff profile not found.");
            request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
            return;
        }
        
        int staffId = staff.getStaffId();
        
        // Calculate dashboard statistics
        
        // 1. Attendance this month
        LocalDate today = LocalDate.now();
        YearMonth currentMonth = YearMonth.now();
        Date startOfMonth = Date.valueOf(currentMonth.atDay(1));
        Date endOfMonth = Date.valueOf(currentMonth.atEndOfMonth());
        
        int attendanceDaysThisMonth = attendanceDAO.getTotalPresentDays(staffId, startOfMonth, endOfMonth);
        
        // 2. Leave Balance
        int currentYear = today.getYear();
        LeaveBalance leaveBalance = leaveBalanceDAO.getLeaveBalance(staffId, currentYear);
        
        if (leaveBalance == null) {
            leaveBalanceDAO.initializeLeaveBalance(staffId, currentYear);
            leaveBalance = leaveBalanceDAO.getLeaveBalance(staffId, currentYear);
        }
        
        int totalLeaveBalance = leaveBalance != null ? leaveBalance.getTotalLeave() : 0;
        
        // 3. Pending Leaves
        List<Leave> allLeaves = leaveDAO.getLeavesByStaffId(staffId);
        long pendingLeavesCount = allLeaves.stream()
                .filter(leave -> "PENDING".equals(leave.getStatus()))
                .count();
        
        // 4. Last Salary
        List<Payroll> payrollList = payrollDAO.getPayrollsByStaffId(staffId);
        BigDecimal lastSalary = BigDecimal.ZERO;
        
        if (payrollList != null && !payrollList.isEmpty()) {
            lastSalary = payrollList.get(0).getNetSalary();
        }
        
        // 5. Recent Activity
        List<Attendance> recentAttendance = attendanceDAO.getAttendanceByStaffId(staffId);
        List<Leave> recentLeaves = allLeaves.stream()
                .limit(5)
                .toList();
        
        // Set attributes for JSP
        request.setAttribute("staff", staff);
        request.setAttribute("attendanceDaysThisMonth", attendanceDaysThisMonth);
        request.setAttribute("totalLeaveBalance", totalLeaveBalance);
        request.setAttribute("pendingLeavesCount", pendingLeavesCount);
        request.setAttribute("lastSalary", lastSalary);
        request.setAttribute("recentAttendance", recentAttendance);
        request.setAttribute("recentLeaves", recentLeaves);
        
        request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
    }
}