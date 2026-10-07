<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.User" %>
<%@ page import="com.smartpayroll.model.Payroll" %>
<%@ page import="com.smartpayroll.model.Staff" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payroll Management - SmartPayroll</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: #f8fafc;
            color: #0f172a;
        }
        
        .dashboard-wrapper {
            display: flex;
            min-height: 100vh;
        }
        
        /* Sidebar Styles */
        .sidebar {
            width: 280px;
            background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
            color: white;
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            z-index: 100;
            box-shadow: 4px 0 24px rgba(0, 0, 0, 0.12);
        }
        
        .sidebar-header {
            padding: 32px 24px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .sidebar-header h2 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .role-badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%);
        }
        
        .sidebar-nav {
            flex: 1;
            padding: 24px 0;
        }
        
        .sidebar-nav ul {
            list-style: none;
        }
        
        .sidebar-nav li {
            margin: 4px 16px;
        }
        
        .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 16px;
            color: #cbd5e1;
            text-decoration: none;
            border-radius: 10px;
            transition: all 0.3s;
            font-weight: 500;
            font-size: 0.95rem;
        }
        
        .sidebar-nav a:hover {
            background: rgba(255, 255, 255, 0.08);
            color: white;
            transform: translateX(4px);
        }
        
        .sidebar-nav li.active a {
            background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
        }
        
        .sidebar-nav .icon {
            font-size: 1.2rem;
            width: 24px;
            text-align: center;
        }
        
        .sidebar-footer {
            padding: 24px 16px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .btn-logout {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 16px;
            background: rgba(239, 68, 68, 0.1);
            color: #fca5a5;
            text-decoration: none;
            border-radius: 10px;
            transition: all 0.3s;
            font-weight: 500;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }
        
        .btn-logout:hover {
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
            transform: translateX(4px);
        }
        
        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 32px;
        }
        
        .page-header {
            margin-bottom: 32px;
        }
        
        .page-header h1 {
            font-size: 2rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 8px;
        }
        
        .page-header p {
            color: #64748b;
            font-size: 0.95rem;
        }
        
        /* Alerts */
        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-size: 0.9rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.3s ease;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .alert-success {
            background: #f0fdf4;
            color: #16a34a;
            border: 1px solid #bbf7d0;
        }
        
        .alert-success::before {
            content: '✓';
            font-size: 1.2rem;
            font-weight: bold;
        }
        
        .alert-error {
            background: #fef2f2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }
        
        .alert-error::before {
            content: '⚠';
            font-size: 1.2rem;
        }
        
        /* Action Bar */
        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }
        
        .action-bar h2 {
            font-size: 1.2rem;
            font-weight: 600;
            color: #0f172a;
        }
        
        .btn-add {
            padding: 12px 24px;
            background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%);
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-add:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
        }
        
        /* Filter Card */
        .filter-card {
            background: white;
            padding: 24px;
            border-radius: 16px;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .filter-card h3 {
            font-size: 1.1rem;
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 20px;
        }
        
        .filter-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            align-items: end;
        }
        
        .filter-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #334155;
            font-size: 0.85rem;
        }
        
        .filter-group select {
            width: 100%;
            padding: 10px 14px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 0.9rem;
            transition: all 0.3s;
            background: #f8fafc;
        }
        
        .filter-group select:focus {
            outline: none;
            border-color: #3b82f6;
            background: white;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
        }
        
        .btn-filter {
            padding: 10px 20px;
            background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%);
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.3s;
        }
        
        .btn-filter:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(59, 130, 246, 0.3);
        }
        
        .btn-clear {
            padding: 10px 20px;
            background: #f1f5f9;
            color: #475569;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }
        
        .btn-clear:hover {
            background: #e2e8f0;
        }
        
        /* Table Container */
        .table-container {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .payroll-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .payroll-table thead {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }
        
        .payroll-table th {
            padding: 16px;
            text-align: left;
            font-weight: 700;
            color: #0f172a;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .payroll-table td {
            padding: 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #475569;
            font-size: 0.9rem;
        }
        
        .payroll-table tbody tr {
            transition: all 0.2s;
        }
        
        .payroll-table tbody tr:hover {
            background: #f8fafc;
        }
        
        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .status-pending {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            color: #78350f;
        }
        
        .status-processed {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #065f46;
        }
        
        .status-paid {
            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
            color: #1e40af;
        }
        
        .table-actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .btn-edit, .btn-delete, .btn-process {
            padding: 8px 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
        }
        
        .btn-edit {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .btn-edit:hover {
            background: #3b82f6;
            color: white;
            transform: translateY(-2px);
        }
        
        .btn-process {
            background: #d1fae5;
            color: #065f46;
        }
        
        .btn-process:hover {
            background: #10b981;
            color: white;
            transform: translateY(-2px);
        }
        
        .btn-delete {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .btn-delete:hover {
            background: #ef4444;
            color: white;
            transform: translateY(-2px);
        }
        
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #94a3b8;
            font-size: 0.95rem;
        }
        
        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.7);
            backdrop-filter: blur(4px);
            animation: fadeIn 0.3s ease;
            overflow-y: auto;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .modal-content {
            background: white;
            margin: 50px auto;
            padding: 0;
            width: 90%;
            max-width: 650px;
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            animation: slideUp 0.3s ease;
        }
        
        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .modal-header {
            padding: 28px 32px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 {
            font-size: 1.5rem;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
        }
        
        .close {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: #94a3b8;
            cursor: pointer;
            transition: all 0.3s;
            background: transparent;
        }
        
        .close:hover {
            background: #f1f5f9;
            color: #0f172a;
        }
        
        .modal-body {
            padding: 32px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #334155;
            font-size: 0.9rem;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 0.95rem;
            transition: all 0.3s;
            background: #f8fafc;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #3b82f6;
            background: white;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
        }
        
        .salary-breakdown {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            padding: 20px;
            border-radius: 12px;
            margin-top: 20px;
            border: 2px solid #e2e8f0;
        }
        
        .salary-breakdown h4 {
            margin: 0 0 16px 0;
            color: #0f172a;
            font-size: 1rem;
        }
        
        .salary-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e2e8f0;
            font-size: 0.9rem;
        }
        
        .salary-row:last-child {
            border-bottom: none;
            font-weight: 700;
            font-size: 1.1rem;
            color: #0f172a;
            padding-top: 12px;
            margin-top: 4px;
            border-top: 2px solid #3b82f6;
        }
        
        .info-box {
            background: #f8fafc;
            padding: 16px;
            border-radius: 12px;
            margin-bottom: 20px;
            border: 1px solid #e2e8f0;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 6px 0;
        }
        
        .info-row strong {
            color: #475569;
        }
        
        .form-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            padding: 24px 32px;
            border-top: 1px solid #f1f5f9;
        }
        
        .btn-submit, .btn-cancel {
            padding: 12px 28px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s;
        }
        
        .btn-submit {
            background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%);
            color: white;
        }
        
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
        }
        
        .btn-cancel {
            background: #f1f5f9;
            color: #475569;
        }
        
        .btn-cancel:hover {
            background: #e2e8f0;
        }
        
        /* Confirmation Modal */
        .confirm-modal-content {
            max-width: 480px;
            text-align: center;
        }
        
        .confirm-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            margin: 0 auto 20px;
        }
        
        .confirm-icon.success {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
        }
        
        .confirm-icon.danger {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
        }
        
        .confirm-modal-content h2 {
            font-size: 1.5rem;
            color: #0f172a;
            margin-bottom: 12px;
        }
        
        .confirm-modal-content p {
            color: #64748b;
            margin-bottom: 12px;
            line-height: 1.6;
        }
        
        .confirm-text {
            font-size: 0.9rem;
            font-weight: 600;
        }
        
        .confirm-text.success {
            color: #16a34a;
        }
        
        .confirm-text.danger {
            color: #dc2626;
        }
        
        .confirm-actions {
            display: flex;
            gap: 12px;
            justify-content: center;
            margin-top: 24px;
        }
        
        .btn-confirm-process {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 12px 32px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s;
        }
        
        .btn-confirm-process:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
        }
        
        .btn-confirm-delete {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: white;
            padding: 12px 32px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s;
        }
        
        .btn-confirm-delete:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(239, 68, 68, 0.3);
        }
        
        .btn-cancel-confirm {
            background: #f1f5f9;
            color: #475569;
            padding: 12px 32px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s;
        }
        
        .btn-cancel-confirm:hover {
            background: #e2e8f0;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .sidebar {
                width: 70px;
            }
            
            .sidebar-header h2 span:last-child,
            .sidebar-nav a span:not(.icon),
            .btn-logout span:not(.icon),
            .role-badge {
                display: none;
            }
            
            .main-content {
                margin-left: 70px;
                padding: 20px;
            }
            
            .filter-row {
                grid-template-columns: 1fr;
            }
            
            .payroll-table {
                font-size: 0.85rem;
            }
            
            .payroll-table th,
            .payroll-table td {
                padding: 12px 8px;
            }
            
            .table-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-wrapper">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <h2>💼 <span>SmartPayroll</span></h2>
                <p class="role-badge admin">Admin</p>
            </div>
            
            <nav class="sidebar-nav">
                <ul>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/dashboard">
                            <span class="icon">📊</span>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff">
                            <span class="icon">👥</span>
                            <span>Manage Staff</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/attendance">
                            <span class="icon">📅</span>
                            <span>Attendance</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="${pageContext.request.contextPath}/admin/payroll">
                            <span class="icon">💰</span>
                            <span>Payroll</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/leave">
                            <span class="icon">🏖️</span>
                            <span>Leave Management</span>
                        </a>
                    </li>
                </ul>
            </nav>
            
            <div class="sidebar-footer">
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                    <span class="icon">🚪</span>
                    <span>Logout</span>
                </a>
            </div>
        </aside>
        
        <!-- Main Content -->
        <main class="main-content">
            <div class="page-header">
                <h1>Payroll Management</h1>
                <p>Process and manage employee salary payments</p>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>
            
            <!-- Action Bar -->
            <div class="action-bar">
                <h2>Payroll Records</h2>
                <button class="btn-add" onclick="openAddModal()">➕ Add New Payroll</button>
            </div>
            
            <!-- Filter Section -->
            <div class="filter-card">
                <h3>Filter Payroll Records</h3>
                <form action="${pageContext.request.contextPath}/admin/payroll" method="get">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="filterMonth">Month</label>
                            <select id="filterMonth" name="filterMonth">
                                <option value="">All Months</option>
                                <option value="January" ${filterMonth == 'January' ? 'selected' : ''}>January</option>
                                <option value="February" ${filterMonth == 'February' ? 'selected' : ''}>February</option>
                                <option value="March" ${filterMonth == 'March' ? 'selected' : ''}>March</option>
                                <option value="April" ${filterMonth == 'April' ? 'selected' : ''}>April</option>
                                <option value="May" ${filterMonth == 'May' ? 'selected' : ''}>May</option>
                                <option value="June" ${filterMonth == 'June' ? 'selected' : ''}>June</option>
                                <option value="July" ${filterMonth == 'July' ? 'selected' : ''}>July</option>
                                <option value="August" ${filterMonth == 'August' ? 'selected' : ''}>August</option>
                                <option value="September" ${filterMonth == 'September' ? 'selected' : ''}>September</option>
                                <option value="October" ${filterMonth == 'October' ? 'selected' : ''}>October</option>
                                <option value="November" ${filterMonth == 'November' ? 'selected' : ''}>November</option>
                                <option value="December" ${filterMonth == 'December' ? 'selected' : ''}>December</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="filterYear">Year</label>
                            <select id="filterYear" name="filterYear">
                                <option value="">All Years</option>
                                <option value="2024" ${filterYear == '2024' ? 'selected' : ''}>2024</option>
                                <option value="2025" ${filterYear == '2025' ? 'selected' : ''}>2025</option>
                                <option value="2026" ${filterYear == '2026' ? 'selected' : ''}>2026</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="filterStatus">Status</label>
                            <select id="filterStatus" name="filterStatus">
                                <option value="">All Status</option>
                                <option value="PENDING" ${filterStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                                <option value="PROCESSED" ${filterStatus == 'PROCESSED' ? 'selected' : ''}>Processed</option>
                                <option value="PAID" ${filterStatus == 'PAID' ? 'selected' : ''}>Paid</option>
                            </select>
                        </div>
                        
                        <button type="submit" class="btn-filter">Apply Filter</button>
                        <a href="${pageContext.request.contextPath}/admin/payroll" class="btn-clear">Clear</a>
                    </div>
                </form>
            </div>
            
            <!-- Payroll Table -->
            <div class="table-container">
                <table class="payroll-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Staff Name</th>
                            <th>Month/Year</th>
                            <th>Basic Salary</th>
                            <th>Bonus</th>
                            <th>Deductions</th>
                            <th>Net Salary</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty payrollList}">
                                <c:forEach var="payroll" items="${payrollList}">
                                    <tr>
                                        <td>${payroll.payrollId}</td>
                                        <td><strong>${payroll.staffName}</strong></td>
                                        <td>${payroll.month} ${payroll.year}</td>
                                        <td>Rs. <fmt:formatNumber value="${payroll.basicSalary}" pattern="#,##0.00"/></td>
                                        <td>Rs. <fmt:formatNumber value="${payroll.bonus}" pattern="#,##0.00"/></td>
                                        <td>Rs. <fmt:formatNumber value="${payroll.deductions}" pattern="#,##0.00"/></td>
                                        <td><strong style="color: #0f172a;">Rs. <fmt:formatNumber value="${payroll.netSalary}" pattern="#,##0.00"/></strong></td>
                                        <td>
                                            <span class="status-badge status-${payroll.status.toLowerCase()}">
                                                ${payroll.status}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="table-actions">
                                                <button class="btn-edit" 
                                                        onclick="openEditModal(${payroll.payrollId}, ${payroll.basicSalary}, ${payroll.bonus}, ${payroll.deductions}, '${payroll.status}', '${payroll.staffName}', '${payroll.month}', ${payroll.year})">
                                                    Edit
                                                </button>
                                                <c:if test="${payroll.status == 'PENDING'}">
                                                    <button class="btn-process" 
                                                            onclick="openProcessModal(${payroll.payrollId}, '${payroll.staffName}', '${payroll.month}', ${payroll.year})">
                                                        Process
                                                    </button>
                                                </c:if>
                                                <button class="btn-delete" 
                                                        onclick="openDeleteModal(${payroll.payrollId}, '${payroll.staffName}', '${payroll.month}', ${payroll.year})">
                                                    Delete
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9" class="no-data">
                                        No payroll records found for the selected filter
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
    
    <!-- Add Payroll Modal -->
    <div id="addModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Add New Payroll</h2>
                <span class="close" onclick="closeAddModal()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/admin/payroll" method="post" onsubmit="return validateAddForm()">
                <div class="modal-body">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-group">
                        <label for="addStaffId">Select Staff *</label>
                        <select id="addStaffId" name="staffId" required onchange="loadStaffSalary()">
                            <option value="">Choose Staff Member</option>
                            <c:forEach var="staff" items="${staffList}">
                                <option value="${staff.staffId}" data-salary="${staff.salary}">
                                    ${staff.name} - ${staff.email}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="addMonth">Month *</label>
                        <select id="addMonth" name="month" required>
                            <option value="">Select Month</option>
                            <option value="January">January</option>
                            <option value="February">February</option>
                            <option value="March">March</option>
                            <option value="April">April</option>
                            <option value="May">May</option>
                            <option value="June">June</option>
                            <option value="July">July</option>
                            <option value="August">August</option>
                            <option value="September">September</option>
                            <option value="October">October</option>
                            <option value="November">November</option>
                            <option value="December">December</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="addYear">Year *</label>
                        <select id="addYear" name="year" required>
                            <option value="">Select Year</option>
                            <option value="2024">2024</option>
                            <option value="2025">2025</option>
                            <option value="2026">2026</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="addBasicSalary">Basic Salary (Rs.) *</label>
                        <input type="number" id="addBasicSalary" name="basicSalary" 
                               placeholder="50000.00" step="0.01" min="0" required oninput="calculateNetSalaryAdd()">
                    </div>
                    
                    <div class="form-group">
                        <label for="addBonus">Bonus (Rs.)</label>
                        <input type="number" id="addBonus" name="bonus" 
                               placeholder="0.00" step="0.01" min="0" value="0" oninput="calculateNetSalaryAdd()">
                    </div>
                    
                    <div class="form-group">
                        <label for="addDeductions">Deductions (Rs.)</label>
                        <input type="number" id="addDeductions" name="deductions" 
                               placeholder="0.00" step="0.01" min="0" value="0" oninput="calculateNetSalaryAdd()">
                    </div>
                    
                    <div class="salary-breakdown">
                        <h4>Salary Breakdown</h4>
                        <div class="salary-row">
                            <span>Basic Salary:</span>
                            <span id="addDisplayBasic">Rs. 0.00</span>
                        </div>
                        <div class="salary-row">
                            <span>Bonus:</span>
                            <span id="addDisplayBonus">Rs. 0.00</span>
                        </div>
                        <div class="salary-row">
                            <span>Gross Salary:</span>
                            <span id="addDisplayGross">Rs. 0.00</span>
                        </div>
                        <div class="salary-row">
                            <span>Deductions:</span>
                            <span id="addDisplayDeductions">Rs. 0.00</span>
                        </div>
                        <div class="salary-row">
                            <span>Net Salary:</span>
                            <span id="addDisplayNet">Rs. 0.00</span>
                        </div>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn-cancel" onclick="closeAddModal()">Cancel</button>
                    <button type="submit" class="btn-submit">Add Payroll</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Edit Payroll Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Payroll</h2>
                <span class="close" onclick="closeEditModal()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/admin/payroll" method="post">
                <div class="modal-body">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" id="editPayrollId" name="payrollId">
                    
                    <div class="info-box">
                        <div class="info-row">
                            <span><strong>Staff:</strong></span>
                            <span id="editStaffInfo"></span>
                        </div>
                        <div class="info-row">
                            <span><strong>Period:</strong></span>
                            <span id="editPeriodInfo"></span>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="editBasicSalary">Basic Salary (Rs.) *</label>
                        <input type="number" id="editBasicSalary" name="basicSalary" 
                               step="0.01" min="0" required oninput="calculateNetSalaryEdit()">
                    </div>
                    
                    <div class="form-group">
                        <label for="editBonus">Bonus (Rs.)</label>
                        <input type="number" id="editBonus" name="bonus" 
                               step="0.01" min="0" oninput="calculateNetSalaryEdit()">
                    </div>
                    
                    <div class="form-group">
                        <label for="editDeductions">Deductions (Rs.)</label>
                        <input type="number" id="editDeductions" name="deductions" 
                               step="0.01" min="0" oninput="calculateNetSalaryEdit()">
                    </div>
                    
                    <div class="form-group">
                        <label for="editStatus">Status *</label>
                        <select id="editStatus" name="status" required>
                            <option value="PENDING">Pending</option>
                            <option value="PROCESSED">Processed</option>
                            <option value="PAID">Paid</option>
                        </select>
                    </div>
                    
                    <div class="salary-breakdown">
                        <h4>Salary Breakdown</h4>
                        <div class="salary-row">
                            <span>Basic Salary:</span>
                            <span id="editDisplayBasic">Rs. 0.00</span>
                        </div>
                        <div class="salary-row">
                            <span>Bonus:</span>
                            <span id="editDisplayBonus">Rs. 0.00</span>
                        </div>
                        <div class="salary-row">
                            <span>Gross Salary:</span>
                            <span id="editDisplayGross">Rs. 0.00</span>
                        </div>
                        <div class="salary-row">
                            <span>Deductions:</span>
                            <span id="editDisplayDeductions">Rs. 0.00</span>
                        </div>
                        <div class="salary-row">
                            <span>Net Salary:</span>
                            <span id="editDisplayNet">Rs. 0.00</span>
                        </div>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn-cancel" onclick="closeEditModal()">Cancel</button>
                    <button type="submit" class="btn-submit">Update Payroll</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Process Confirmation Modal -->
    <div id="processModal" class="modal">
        <div class="modal-content confirm-modal-content">
            <div class="modal-body">
                <div class="confirm-icon success">✓</div>
                <h2>Process Payroll?</h2>
                <p>Are you sure you want to process payroll for <strong id="processStaffName"></strong> 
                for <strong id="processPeriod"></strong>?</p>
                <p class="confirm-text success">This will mark the payroll as processed.</p>
                
                <div class="confirm-actions">
                    <button class="btn-cancel-confirm" onclick="closeProcessModal()">Cancel</button>
                    <button class="btn-confirm-process" onclick="confirmProcess()">Yes, Process</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="modal-content confirm-modal-content">
            <div class="modal-body">
                <div class="confirm-icon danger">⚠️</div>
                <h2>Delete Payroll Record?</h2>
                <p>Are you sure you want to delete payroll for <strong id="deleteStaffName"></strong> 
                for <strong id="deletePeriod"></strong>?</p>
                <p class="confirm-text danger">This action cannot be undone.</p>
                
                <div class="confirm-actions">
                    <button class="btn-cancel-confirm" onclick="closeDeleteModal()">Cancel</button>
                    <button class="btn-confirm-delete" onclick="confirmDelete()">Yes, Delete</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Hidden Forms -->
    <form id="processForm" action="${pageContext.request.contextPath}/admin/payroll" method="post" style="display: none;">
        <input type="hidden" name="action" value="process">
        <input type="hidden" id="processPayrollId" name="payrollId">
    </form>
    
    <form id="deleteForm" action="${pageContext.request.contextPath}/admin/payroll" method="post" style="display: none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" id="deletePayrollId" name="payrollId">
    </form>
    
    <script>
        let currentProcessId = null;
        let currentDeleteId = null;
        
        // Add Modal Functions
        function openAddModal() {
            document.getElementById('addModal').style.display = 'block';
        }
        
        function closeAddModal() {
            document.getElementById('addModal').style.display = 'none';
            document.querySelector('#addModal form').reset();
            calculateNetSalaryAdd();
        }
        
        function loadStaffSalary() {
            const select = document.getElementById('addStaffId');
            const selectedOption = select.options[select.selectedIndex];
            const salary = selectedOption.getAttribute('data-salary');
            
            if (salary) {
                document.getElementById('addBasicSalary').value = salary;
                calculateNetSalaryAdd();
            }
        }
        
        function calculateNetSalaryAdd() {
            const basic = parseFloat(document.getElementById('addBasicSalary').value) || 0;
            const bonus = parseFloat(document.getElementById('addBonus').value) || 0;
            const deductions = parseFloat(document.getElementById('addDeductions').value) || 0;
            
            const gross = basic + bonus;
            const net = gross - deductions;
            
            document.getElementById('addDisplayBasic').textContent = 'Rs. ' + basic.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('addDisplayBonus').textContent = 'Rs. ' + bonus.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('addDisplayGross').textContent = 'Rs. ' + gross.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('addDisplayDeductions').textContent = 'Rs. ' + deductions.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('addDisplayNet').textContent = 'Rs. ' + net.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }
        
        function validateAddForm() {
            const staffId = document.getElementById('addStaffId').value;
            const month = document.getElementById('addMonth').value;
            const year = document.getElementById('addYear').value;
            const basicSalary = parseFloat(document.getElementById('addBasicSalary').value);
            
            if (!staffId || !month || !year) {
                alert('Please fill in all required fields');
                return false;
            }
            
            if (basicSalary <= 0) {
                alert('Basic salary must be greater than zero');
                return false;
            }
            
            return true;
        }
        
        // Edit Modal Functions
        function openEditModal(id, basic, bonus, deductions, status, staffName, month, year) {
            document.getElementById('editPayrollId').value = id;
            document.getElementById('editBasicSalary').value = basic;
            document.getElementById('editBonus').value = bonus;
            document.getElementById('editDeductions').value = deductions;
            document.getElementById('editStatus').value = status;
            
            document.getElementById('editStaffInfo').textContent = staffName;
            document.getElementById('editPeriodInfo').textContent = month + ' ' + year;
            
            calculateNetSalaryEdit();
            document.getElementById('editModal').style.display = 'block';
        }
        
        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
        }
        
        function calculateNetSalaryEdit() {
            const basic = parseFloat(document.getElementById('editBasicSalary').value) || 0;
            const bonus = parseFloat(document.getElementById('editBonus').value) || 0;
            const deductions = parseFloat(document.getElementById('editDeductions').value) || 0;
            
            const gross = basic + bonus;
            const net = gross - deductions;
            
            document.getElementById('editDisplayBasic').textContent = 'Rs. ' + basic.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('editDisplayBonus').textContent = 'Rs. ' + bonus.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('editDisplayGross').textContent = 'Rs. ' + gross.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('editDisplayDeductions').textContent = 'Rs. ' + deductions.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('editDisplayNet').textContent = 'Rs. ' + net.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }
        
        // Process Modal Functions
        function openProcessModal(id, staffName, month, year) {
            currentProcessId = id;
            document.getElementById('processStaffName').textContent = staffName;
            document.getElementById('processPeriod').textContent = month + ' ' + year;
            document.getElementById('processModal').style.display = 'block';
        }
        
        function closeProcessModal() {
            document.getElementById('processModal').style.display = 'none';
            currentProcessId = null;
        }
        
        function confirmProcess() {
            if (currentProcessId) {
                document.getElementById('processPayrollId').value = currentProcessId;
                document.getElementById('processForm').submit();
            }
        }
        
        // Delete Modal Functions
        function openDeleteModal(id, staffName, month, year) {
            currentDeleteId = id;
            document.getElementById('deleteStaffName').textContent = staffName;
            document.getElementById('deletePeriod').textContent = month + ' ' + year;
            document.getElementById('deleteModal').style.display = 'block';
        }
        
        function closeDeleteModal() {
            document.getElementById('deleteModal').style.display = 'none';
            currentDeleteId = null;
        }
        
        function confirmDelete() {
            if (currentDeleteId) {
                document.getElementById('deletePayrollId').value = currentDeleteId;
                document.getElementById('deleteForm').submit();
            }
        }
        
        // Close modals when clicking outside
        window.onclick = function(event) {
            const addModal = document.getElementById('addModal');
            const editModal = document.getElementById('editModal');
            const processModal = document.getElementById('processModal');
            const deleteModal = document.getElementById('deleteModal');
            
            if (event.target == addModal) {
                closeAddModal();
            }
            if (event.target == editModal) {
                closeEditModal();
            }
            if (event.target == processModal) {
                closeProcessModal();
            }
            if (event.target == deleteModal) {
                closeDeleteModal();
            }
        }
        
        // Initialize calculations on page load
        document.addEventListener('DOMContentLoaded', function() {
            calculateNetSalaryAdd();
        });
    </script>
</body>
</html>