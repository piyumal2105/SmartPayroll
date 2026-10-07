package com.smartpayroll.controller;

import com.smartpayroll.dao.LeaveDAO;
import com.smartpayroll.dao.LeaveBalanceDAO;
import com.smartpayroll.model.Leave;
import com.smartpayroll.model.LeaveBalance;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/staff/leave")
public class StaffLeaveController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private LeaveDAO leaveDAO;
    private LeaveBalanceDAO leaveBalanceDAO;
    
    @Override
    public void init() {
        leaveDAO = new LeaveDAO();
        leaveBalanceDAO = new LeaveBalanceDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
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
            request.setAttribute("error", "Staff ID not found in session.");
            request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
            return;
        }
        
        // Get current year
        int currentYear = LocalDate.now().getYear();
        
        // Get or initialize leave balance
        LeaveBalance balance = leaveBalanceDAO.getLeaveBalance(staffId, currentYear);
        if (balance == null) {
            leaveBalanceDAO.initializeLeaveBalance(staffId, currentYear);
            balance = leaveBalanceDAO.getLeaveBalance(staffId, currentYear);
        }
        
        // Get leave history
        List<Leave> leaveList = leaveDAO.getLeavesByStaffId(staffId);
        
        request.setAttribute("leaveBalance", balance);
        request.setAttribute("leaveList", leaveList);
        
        request.getRequestDispatcher("/views/staff/leave.jsp").forward(request, response);
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
        
        if ("apply".equals(action)) {
            applyLeave(request, response, staffId);
        } else if ("update".equals(action)) {
            updateLeave(request, response, staffId);
        } else if ("delete".equals(action)) {
            deleteLeave(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/leave");
        }
    }
    
    private void applyLeave(HttpServletRequest request, HttpServletResponse response, int staffId) 
            throws ServletException, IOException {
        
        String leaveType = request.getParameter("leaveType");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String reason = request.getParameter("reason");
        
        try {
            Date startDate = Date.valueOf(startDateStr);
            Date endDate = Date.valueOf(endDateStr);
            
            // Validate dates
            if (endDate.before(startDate)) {
                request.setAttribute("error", "End date cannot be before start date.");
                doGet(request, response);
                return;
            }
            
            // Calculate duration
            long diff = endDate.getTime() - startDate.getTime();
            int days = (int) (diff / (1000 * 60 * 60 * 24)) + 1;
            
            // Check for overlapping leaves
            if (leaveDAO.hasOverlappingLeave(staffId, startDate, endDate, null)) {
                request.setAttribute("error", "You already have an approved leave during this period.");
                doGet(request, response);
                return;
            }
            
            // Check leave balance for SICK, CASUAL, ANNUAL
            int currentYear = LocalDate.now().getYear();
            if (leaveType.equals("SICK") || leaveType.equals("CASUAL") || leaveType.equals("ANNUAL")) {
                if (!leaveBalanceDAO.hasSufficientBalance(staffId, currentYear, leaveType, days)) {
                    request.setAttribute("error", "Insufficient leave balance for " + leaveType + " leave.");
                    doGet(request, response);
                    return;
                }
            }
            
            // Create leave request
            Leave leave = new Leave(staffId, leaveType, startDate, endDate, reason);
            
            boolean success = leaveDAO.applyLeave(leave);
            
            if (success) {
                request.setAttribute("success", "Leave request submitted successfully! Waiting for approval.");
            } else {
                request.setAttribute("error", "Failed to submit leave request. Please try again.");
            }
            
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid date format.");
        } catch (Exception e) {
            request.setAttribute("error", "Error processing leave request: " + e.getMessage());
        }
        
        doGet(request, response);
    }
    
    private void updateLeave(HttpServletRequest request, HttpServletResponse response, int staffId) 
            throws ServletException, IOException {
        
        String leaveIdStr = request.getParameter("leaveId");
        String leaveType = request.getParameter("leaveType");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String reason = request.getParameter("reason");
        
        try {
            int leaveId = Integer.parseInt(leaveIdStr);
            Date startDate = Date.valueOf(startDateStr);
            Date endDate = Date.valueOf(endDateStr);
            
            // Validate dates
            if (endDate.before(startDate)) {
                request.setAttribute("error", "End date cannot be before start date.");
                doGet(request, response);
                return;
            }
            
            // Calculate duration
            long diff = endDate.getTime() - startDate.getTime();
            int days = (int) (diff / (1000 * 60 * 60 * 24)) + 1;
            
            // Check for overlapping leaves (excluding current leave)
            if (leaveDAO.hasOverlappingLeave(staffId, startDate, endDate, leaveId)) {
                request.setAttribute("error", "Leave dates overlap with another approved leave.");
                doGet(request, response);
                return;
            }
            
            // Check leave balance
            int currentYear = LocalDate.now().getYear();
            if (leaveType.equals("SICK") || leaveType.equals("CASUAL") || leaveType.equals("ANNUAL")) {
                if (!leaveBalanceDAO.hasSufficientBalance(staffId, currentYear, leaveType, days)) {
                    request.setAttribute("error", "Insufficient leave balance for " + leaveType + " leave.");
                    doGet(request, response);
                    return;
                }
            }
            
            // Update leave
            Leave leave = new Leave();
            leave.setLeaveId(leaveId);
            leave.setLeaveType(leaveType);
            leave.setStartDate(startDate);
            leave.setEndDate(endDate);
            leave.setReason(reason);
            
            boolean success = leaveDAO.updateLeave(leave);
            
            if (success) {
                request.setAttribute("success", "Leave request updated successfully!");
            } else {
                request.setAttribute("error", "Failed to update leave request. It may have already been processed.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid leave ID.");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid date format.");
        } catch (Exception e) {
            request.setAttribute("error", "Error updating leave request: " + e.getMessage());
        }
        
        doGet(request, response);
    }
    
    private void deleteLeave(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String leaveIdStr = request.getParameter("leaveId");
        
        try {
            int leaveId = Integer.parseInt(leaveIdStr);
            boolean success = leaveDAO.deleteLeave(leaveId);
            
            if (success) {
                request.setAttribute("success", "Leave request deleted successfully!");
            } else {
                request.setAttribute("error", "Failed to delete leave request. It may have already been processed.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid leave ID.");
        }
        
        doGet(request, response);
    }
}