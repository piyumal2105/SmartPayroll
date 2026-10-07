package com.smartpayroll.controller;

import com.smartpayroll.dao.StaffDAO;
import com.smartpayroll.model.Staff;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/manage-staff")
public class ManageStaffController extends HttpServlet {
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
        
        // Get all staff
        List<Staff> staffList = staffDAO.getAllStaff();
        request.setAttribute("staffList", staffList);
        
        request.getRequestDispatcher("/views/admin/manage-staff.jsp").forward(request, response);
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
        
        if ("add".equals(action)) {
            addStaff(request, response);
        } else if ("update".equals(action)) {
            updateStaff(request, response);
        } else if ("delete".equals(action)) {
            deleteStaff(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff");
        }
    }
    
    private void addStaff(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String nic = request.getParameter("nic");
        String phone = request.getParameter("phone");
        String staffRole = request.getParameter("staffRole");
        String salaryStr = request.getParameter("salary");
        
        // Validate input
        if (name == null || name.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            nic == null || nic.trim().isEmpty() ||
            staffRole == null || staffRole.trim().isEmpty() ||
            salaryStr == null || salaryStr.trim().isEmpty()) {
            
            request.setAttribute("error", "All required fields must be filled.");
            List<Staff> staffList = staffDAO.getAllStaff();
            request.setAttribute("staffList", staffList);
            request.getRequestDispatcher("/views/admin/manage-staff.jsp").forward(request, response);
            return;
        }
        
        // Check if email already exists
        if (staffDAO.emailExists(email.trim())) {
            request.setAttribute("error", "Email already exists.");
            List<Staff> staffList = staffDAO.getAllStaff();
            request.setAttribute("staffList", staffList);
            request.getRequestDispatcher("/views/admin/manage-staff.jsp").forward(request, response);
            return;
        }
        
        // Check if NIC already exists
        if (staffDAO.nicExists(nic.trim())) {
            request.setAttribute("error", "NIC already exists.");
            List<Staff> staffList = staffDAO.getAllStaff();
            request.setAttribute("staffList", staffList);
            request.getRequestDispatcher("/views/admin/manage-staff.jsp").forward(request, response);
            return;
        }
        
        try {
            double salary = Double.parseDouble(salaryStr);
            
            Staff staff = new Staff(
                name.trim(),
                email.trim(),
                nic.trim(),
                phone != null ? phone.trim() : "",
                staffRole.trim(),
                salary
            );
            
            boolean success = staffDAO.addStaff(staff);
            
            if (success) {
                request.setAttribute("success", "Staff member added successfully!");
            } else {
                request.setAttribute("error", "Failed to add staff member. Please try again.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid salary amount.");
        }
        
        // Reload staff list
        List<Staff> staffList = staffDAO.getAllStaff();
        request.setAttribute("staffList", staffList);
        request.getRequestDispatcher("/views/admin/manage-staff.jsp").forward(request, response);
    }
    
    private void updateStaff(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String staffIdStr = request.getParameter("staffId");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String nic = request.getParameter("nic");
        String phone = request.getParameter("phone");
        String staffRole = request.getParameter("staffRole");
        String salaryStr = request.getParameter("salary");
        
        try {
            int staffId = Integer.parseInt(staffIdStr);
            double salary = Double.parseDouble(salaryStr);
            
            Staff staff = new Staff();
            staff.setStaffId(staffId);
            staff.setName(name.trim());
            staff.setEmail(email.trim());
            staff.setNic(nic.trim());
            staff.setPhone(phone != null ? phone.trim() : "");
            staff.setRole(staffRole.trim());
            staff.setSalary(salary);
            
            boolean success = staffDAO.updateStaff(staff);
            
            if (success) {
                request.setAttribute("success", "Staff member updated successfully!");
            } else {
                request.setAttribute("error", "Failed to update staff member.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid input values.");
        }
        
        // Reload staff list
        List<Staff> staffList = staffDAO.getAllStaff();
        request.setAttribute("staffList", staffList);
        request.getRequestDispatcher("/views/admin/manage-staff.jsp").forward(request, response);
    }
    
    private void deleteStaff(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String staffIdStr = request.getParameter("staffId");
        
        try {
            int staffId = Integer.parseInt(staffIdStr);
            boolean success = staffDAO.deleteStaff(staffId);
            
            if (success) {
                request.setAttribute("success", "Staff member deleted successfully!");
            } else {
                request.setAttribute("error", "Failed to delete staff member.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid staff ID.");
        }
        
        // Reload staff list
        List<Staff> staffList = staffDAO.getAllStaff();
        request.setAttribute("staffList", staffList);
        request.getRequestDispatcher("/views/admin/manage-staff.jsp").forward(request, response);
    }
}