package com.smartpayroll.controller;

import com.smartpayroll.dao.LeaveDAO;
import com.smartpayroll.dao.LeaveBalanceDAO;
import com.smartpayroll.model.Leave;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/admin/leave")
public class AdminLeaveController extends HttpServlet {
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
        if (!"ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String filterStatus = request.getParameter("filterStatus");
        String filterType = request.getParameter("filterType");
        
        List<Leave> leaveList;
        
        // Apply filters
        if (filterStatus != null && !filterStatus.trim().isEmpty()) {
            leaveList = leaveDAO.getAllLeaves().stream()
                .filter(l -> l.getStatus().equals(filterStatus))
                .toList();
        } else if (filterType != null && !filterType.trim().isEmpty()) {
            leaveList = leaveDAO.getAllLeaves().stream()
                .filter(l -> l.getLeaveType().equals(filterType))
                .toList();
        } else {
            leaveList = leaveDAO.getAllLeaves();
        }
        
        // Calculate statistics
        long pendingCount = leaveList.stream().filter(l -> "PENDING".equals(l.getStatus())).count();
        long approvedCount = leaveList.stream().filter(l -> "APPROVED".equals(l.getStatus())).count();
        long rejectedCount = leaveList.stream().filter(l -> "REJECTED".equals(l.getStatus())).count();
        
        request.setAttribute("leaveList", leaveList);
        request.setAttribute("filterStatus", filterStatus);
        request.setAttribute("filterType", filterType);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
        request.setAttribute("totalCount", leaveList.size());
        
        request.getRequestDispatcher("/views/admin/leave.jsp").forward(request, response);
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
        
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            request.setAttribute("error", "User ID not found.");
            doGet(request, response);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("approve".equals(action)) {
            approveLeave(request, response, userId);
        } else if ("reject".equals(action)) {
            rejectLeave(request, response, userId);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/leave");
        }
    }
    
    private void approveLeave(HttpServletRequest request, HttpServletResponse response, int approvedBy) 
            throws ServletException, IOException {
        
        String leaveIdStr = request.getParameter("leaveId");
        String remarks = request.getParameter("remarks");
        
        try {
            int leaveId = Integer.parseInt(leaveIdStr);
            
            // Get leave details
            Leave leave = leaveDAO.getLeaveById(leaveId);
            if (leave == null) {
                request.setAttribute("error", "Leave request not found.");
                doGet(request, response);
                return;
            }
            
            // Calculate duration
            long diff = leave.getEndDate().getTime() - leave.getStartDate().getTime();
            int days = (int) (diff / (1000 * 60 * 60 * 24)) + 1;
            
            // Get current year
            int currentYear = LocalDate.now().getYear();
            
            // Deduct leave balance for applicable leave types
            if (leave.getLeaveType().equals("SICK") || 
                leave.getLeaveType().equals("CASUAL") || 
                leave.getLeaveType().equals("ANNUAL")) {
                
                // Check if staff has sufficient balance
                if (!leaveBalanceDAO.hasSufficientBalance(leave.getStaffId(), currentYear, 
                                                          leave.getLeaveType(), days)) {
                    request.setAttribute("error", "Staff member has insufficient " + 
                                       leave.getLeaveType() + " leave balance.");
                    doGet(request, response);
                    return;
                }
                
                // Deduct balance
                leaveBalanceDAO.deductLeaveBalance(leave.getStaffId(), currentYear, 
                                                   leave.getLeaveType(), days);
            }
            
            // Approve leave
            boolean success = leaveDAO.updateLeaveStatus(leaveId, "APPROVED", approvedBy, 
                                                        remarks != null ? remarks : "");
            
            if (success) {
                request.setAttribute("success", "Leave request approved successfully!");
            } else {
                request.setAttribute("error", "Failed to approve leave request.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid leave ID.");
        } catch (Exception e) {
            request.setAttribute("error", "Error approving leave: " + e.getMessage());
        }
        
        doGet(request, response);
    }
    
    private void rejectLeave(HttpServletRequest request, HttpServletResponse response, int approvedBy) 
            throws ServletException, IOException {
        
        String leaveIdStr = request.getParameter("leaveId");
        String remarks = request.getParameter("remarks");
        
        // Validate remarks
        if (remarks == null || remarks.trim().isEmpty()) {
            request.setAttribute("error", "Please provide a reason for rejection.");
            doGet(request, response);
            return;
        }
        
        try {
            int leaveId = Integer.parseInt(leaveIdStr);
            
            boolean success = leaveDAO.updateLeaveStatus(leaveId, "REJECTED", approvedBy, remarks);
            
            if (success) {
                request.setAttribute("success", "Leave request rejected.");
            } else {
                request.setAttribute("error", "Failed to reject leave request.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid leave ID.");
        }
        
        doGet(request, response);
    }
}