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
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/admin/payroll")
public class AdminPayrollServlet extends HttpServlet {
    
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
        
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get filter parameters
        String filterMonth = request.getParameter("filterMonth");
        String filterYearStr = request.getParameter("filterYear");
        String filterStatus = request.getParameter("filterStatus");

        List<Payroll> payrollList;
        
        // Apply filters if provided
        if ((filterMonth != null && !filterMonth.isEmpty()) || 
            (filterYearStr != null && !filterYearStr.isEmpty()) ||
            (filterStatus != null && !filterStatus.isEmpty())) {
            
            Integer filterYear = null;
            if (filterYearStr != null && !filterYearStr.isEmpty()) {
                filterYear = Integer.parseInt(filterYearStr);
            }
            
            payrollList = payrollDAO.filterPayrolls(filterMonth, filterYear, filterStatus);
        } else {
            payrollList = payrollDAO.getAllPayrolls();
        }

        // Get all staff for the add payroll dropdown
        List<Staff> staffList = staffDAO.getAllStaff();

        request.setAttribute("payrollList", payrollList);
        request.setAttribute("staffList", staffList);
        request.setAttribute("filterMonth", filterMonth);
        request.setAttribute("filterYear", filterYearStr);
        request.setAttribute("filterStatus", filterStatus);

        request.getRequestDispatcher("/views/admin/payroll.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        switch (action) {
            case "add":
                addPayroll(request, response);
                break;
            case "update":
                updatePayroll(request, response);
                break;
            case "process":
                processPayroll(request, response);
                break;
            case "delete":
                deletePayroll(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/payroll");
        }
    }

    private void addPayroll(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            String month = request.getParameter("month");
            int year = Integer.parseInt(request.getParameter("year"));
            BigDecimal basicSalary = new BigDecimal(request.getParameter("basicSalary"));
            BigDecimal bonus = new BigDecimal(request.getParameter("bonus"));
            BigDecimal deductions = new BigDecimal(request.getParameter("deductions"));

            // Check if payroll already exists
            if (payrollDAO.payrollExists(staffId, month, year, null)) {
                request.getSession().setAttribute("error", 
                    "Payroll for this staff member already exists for " + month + " " + year);
                response.sendRedirect(request.getContextPath() + "/admin/payroll");
                return;
            }

            Payroll payroll = new Payroll(staffId, month, year, basicSalary, bonus, deductions);
            
            if (payrollDAO.addPayroll(payroll)) {
                request.getSession().setAttribute("success", "Payroll added successfully!");
            } else {
                request.getSession().setAttribute("error", "Failed to add payroll.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Error adding payroll: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/payroll");
    }

    private void updatePayroll(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int payrollId = Integer.parseInt(request.getParameter("payrollId"));
            BigDecimal basicSalary = new BigDecimal(request.getParameter("basicSalary"));
            BigDecimal bonus = new BigDecimal(request.getParameter("bonus"));
            BigDecimal deductions = new BigDecimal(request.getParameter("deductions"));
            String status = request.getParameter("status");

            Payroll payroll = payrollDAO.getPayrollById(payrollId);
            if (payroll != null) {
                payroll.setBasicSalary(basicSalary);
                payroll.setBonus(bonus);
                payroll.setDeductions(deductions);
                payroll.setStatus(status);
                
                if (payrollDAO.updatePayroll(payroll)) {
                    request.getSession().setAttribute("success", "Payroll updated successfully!");
                } else {
                    request.getSession().setAttribute("error", "Failed to update payroll.");
                }
            } else {
                request.getSession().setAttribute("error", "Payroll not found.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Error updating payroll: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/payroll");
    }

    private void processPayroll(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int payrollId = Integer.parseInt(request.getParameter("payrollId"));
            
            if (payrollDAO.processPayroll(payrollId)) {
                request.getSession().setAttribute("success", "Payroll processed successfully!");
            } else {
                request.getSession().setAttribute("error", "Failed to process payroll.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Error processing payroll: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/payroll");
    }

    private void deletePayroll(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int payrollId = Integer.parseInt(request.getParameter("payrollId"));
            
            if (payrollDAO.deletePayroll(payrollId)) {
                request.getSession().setAttribute("success", "Payroll deleted successfully!");
            } else {
                request.getSession().setAttribute("error", "Failed to delete payroll.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Error deleting payroll: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/payroll");
    }
}