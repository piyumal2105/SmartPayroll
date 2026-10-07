package com.smartpayroll.controller;

import com.smartpayroll.dao.PayrollDAO;
import com.smartpayroll.dao.StaffDAO;
import com.smartpayroll.model.Payroll;
import com.smartpayroll.model.Staff;
import com.smartpayroll.model.User;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;

@WebServlet("/staff/payroll")
public class StaffPayrollServlet extends HttpServlet {
    
    private PayrollDAO payrollDAO;
    private StaffDAO staffDAO;

    @Override
    public void init() {
        payrollDAO = new PayrollDAO();
        staffDAO = new StaffDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || !"STAFF".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get staff details
        Staff staff = staffDAO.getStaffByEmail(user.getEmail());
        
        if (staff == null) {
            request.setAttribute("error", "Staff profile not found.");
            request.getRequestDispatcher("/views/staff/payroll.jsp").forward(request, response);
            return;
        }

        // Get payroll history for this staff member
        List<Payroll> payrollList = payrollDAO.getPayrollsByStaffId(staff.getStaffId());

        request.setAttribute("staff", staff);
        request.setAttribute("payrollList", payrollList);

        request.getRequestDispatcher("/views/staff/payroll.jsp").forward(request, response);
    }
}