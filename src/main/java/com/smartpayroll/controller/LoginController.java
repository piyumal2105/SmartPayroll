package com.smartpayroll.controller;

import com.smartpayroll.dao.UserDAO;
import com.smartpayroll.dao.StaffDAO;
import com.smartpayroll.model.User;
import com.smartpayroll.model.Staff;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/login")
public class LoginController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private StaffDAO staffDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
        staffDAO = new StaffDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            String role = (String) session.getAttribute("userRole");
            redirectToDashboard(response, role, request.getContextPath());
            return;
        }
        
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String nic = request.getParameter("nic");
        
        // Validate common required fields
        if (email == null || email.trim().isEmpty() || 
            role == null || role.trim().isEmpty()) {
            request.setAttribute("error", "Email and role are required.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        
        User user = null;
        
        // Authenticate based on role
        if ("ADMIN".equals(role)) {
            // Admin requires password
            if (password == null || password.trim().isEmpty()) {
                request.setAttribute("error", "Password is required for admin login.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
                return;
            }
            user = userDAO.authenticateAdmin(email.trim(), password);
            
        } else if ("STAFF".equals(role)) {
            // Staff requires NIC only (no password)
            if (nic == null || nic.trim().isEmpty()) {
                request.setAttribute("error", "NIC is required for staff login.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
                return;
            }
            user = userDAO.authenticateStaff(email.trim(), nic.trim());
        }
        
        if (user != null && role.equals(user.getRole())) {
            // Create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("userEmail", user.getEmail());
            
            // For staff, also get and store staff details
            if ("STAFF".equals(role)) {
                Staff staff = staffDAO.getStaffByEmail(email.trim());
                if (staff != null) {
                    session.setAttribute("staff", staff);
                    session.setAttribute("staffId", staff.getStaffId());
                    session.setAttribute("staffName", staff.getName());
                }
            }
            
            session.setMaxInactiveInterval(30 * 60); // 30 minutes
            
            // Redirect based on role
            redirectToDashboard(response, user.getRole(), request.getContextPath());
        } else {
            String errorMsg = "ADMIN".equals(role) ? 
                "Invalid email or password." : 
                "Invalid email or NIC.";
            request.setAttribute("error", errorMsg);
            request.setAttribute("email", email);
            request.setAttribute("nic", nic);
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        }
    }
    
    private void redirectToDashboard(HttpServletResponse response, String role, String contextPath) 
            throws IOException {
        if ("ADMIN".equals(role)) {
            response.sendRedirect(contextPath + "/admin/dashboard");
        } else if ("STAFF".equals(role)) {
            response.sendRedirect(contextPath + "/staff/dashboard");
        }
    }
}