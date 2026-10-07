package com.smartpayroll.controller;

import com.smartpayroll.dao.StaffDAO;
import com.smartpayroll.model.Staff;
import com.smartpayroll.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/staff/profile")
public class StaffProfileController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private StaffDAO staffDAO;
    
    @Override
    public void init() {
        staffDAO = new StaffDAO();
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
        
        // Get staff details
        User user = (User) session.getAttribute("user");
        Staff staff = staffDAO.getStaffByEmail(user.getEmail());
        
        if (staff == null) {
            request.setAttribute("error", "Staff profile not found.");
            request.getRequestDispatcher("/views/staff/dashboard.jsp").forward(request, response);
            return;
        }
        
        request.setAttribute("staff", staff);
        request.getRequestDispatcher("/views/staff/profile.jsp").forward(request, response);
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
        
        String action = request.getParameter("action");
        
        if ("update".equals(action)) {
            updateProfile(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/profile");
        }
    }
    
    private void updateProfile(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        User user = (User) session.getAttribute("user");
        Staff staff = staffDAO.getStaffByEmail(user.getEmail());
        
        if (staff == null) {
            request.setAttribute("error", "Staff profile not found.");
            doGet(request, response);
            return;
        }
        
        String phone = request.getParameter("phone");
        
        // Update only phone number (staff can only edit their contact info)
        staff.setPhone(phone != null ? phone.trim() : "");
        
        boolean success = staffDAO.updateStaff(staff);
        
        if (success) {
            request.setAttribute("success", "Profile updated successfully!");
        } else {
            request.setAttribute("error", "Failed to update profile. Please try again.");
        }
        
        doGet(request, response);
    }
}