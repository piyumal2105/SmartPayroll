<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.User" %>
<%@ page import="com.smartpayroll.model.Staff" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <title>Manage Staff - SmartPayroll</title>
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
        
        /* Filter Section */
        .filter-card {
            background: white;
            padding: 24px;
            border-radius: 16px;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .filter-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .filter-header h3 {
            font-size: 1.1rem;
            font-weight: 600;
            color: #0f172a;
        }
        
        .filter-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 16px;
        }
        
        .filter-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #334155;
            font-size: 0.85rem;
        }
        
        .filter-group input,
        .filter-group select {
            width: 100%;
            padding: 10px 14px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 0.9rem;
            transition: all 0.3s;
            background: #f8fafc;
        }
        
        .filter-group input:focus,
        .filter-group select:focus {
            outline: none;
            border-color: #3b82f6;
            background: white;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
        }
        
        .filter-actions {
            display: flex;
            gap: 12px;
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
        }
        
        .btn-clear:hover {
            background: #e2e8f0;
        }
        
        /* Action Bar */
        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            gap: 16px;
            flex-wrap: wrap;
        }
        
        .action-bar h2 {
            font-size: 1.2rem;
            font-weight: 600;
            color: #0f172a;
        }
        
        .action-bar h2 span {
            color: #3b82f6;
        }
        
        .action-buttons {
            display: flex;
            gap: 12px;
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
        
        .btn-report {
            padding: 12px 24px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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
        
        .btn-report:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
        }
        
        /* Staff Table */
        .table-container {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .staff-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .staff-table thead {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }
        
        .staff-table th {
            padding: 16px;
            text-align: left;
            font-weight: 700;
            color: #0f172a;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .staff-table td {
            padding: 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #475569;
            font-size: 0.9rem;
        }
        
        .staff-table tbody tr {
            transition: all 0.2s;
        }
        
        .staff-table tbody tr:hover {
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
        
        .status-active {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #065f46;
        }
        
        .status-inactive {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            color: #991b1b;
        }
        
        .table-actions {
            display: flex;
            gap: 8px;
        }
        
        .btn-edit, .btn-delete {
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
            max-width: 600px;
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
        
        /* Delete Modal */
        .delete-modal-content {
            max-width: 480px;
            text-align: center;
        }
        
        .delete-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.5rem;
            margin: 0 auto 20px;
        }
        
        .delete-modal-content h2 {
            font-size: 1.5rem;
            color: #0f172a;
            margin-bottom: 12px;
        }
        
        .delete-modal-content p {
            color: #64748b;
            margin-bottom: 12px;
            line-height: 1.6;
        }
        
        .delete-staff-name {
            font-weight: 700;
            color: #0f172a;
        }
        
        .warning-text {
            color: #dc2626;
            font-size: 0.9rem;
            font-weight: 600;
        }
        
        .delete-actions {
            display: flex;
            gap: 12px;
            justify-content: center;
            margin-top: 24px;
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
        
        .btn-cancel-delete {
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
        
        .btn-cancel-delete:hover {
            background: #e2e8f0;
        }
        
        /* Print Styles */
        @media print {
            .sidebar, .action-bar, .filter-card, .btn-edit, .btn-delete, .no-print {
                display: none !important;
            }
            
            .main-content {
                margin: 0;
                padding: 20px;
            }
            
            .table-container {
                box-shadow: none;
                border: 1px solid #000;
            }
            
            body {
                background: white;
            }
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
            
            .action-bar {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .staff-table {
                font-size: 0.85rem;
            }
            
            .staff-table th,
            .staff-table td {
                padding: 12px 8px;
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
                    <li class="active">
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
                    <li>
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
                <h1>Manage Staff</h1>
                <p>Add, edit, and manage employee information</p>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>
            
            <!-- Filter Section -->
            <div class="filter-card no-print">
                <div class="filter-header">
                    <h3>Filter Staff Members</h3>
                </div>
                <div class="filter-row">
                    <div class="filter-group">
                        <label for="filterName">Name</label>
                        <input type="text" id="filterName" placeholder="Search by name">
                    </div>
                    <div class="filter-group">
                        <label for="filterRole">Role</label>
                        <select id="filterRole">
                            <option value="">All Roles</option>
                            <option value="Manager">Manager</option>
                            <option value="Supervisor">Supervisor</option>
                            <option value="Developer">Developer</option>
                            <option value="Designer">Designer</option>
                            <option value="Accountant">Accountant</option>
                            <option value="HR Officer">HR Officer</option>
                            <option value="Sales Executive">Sales Executive</option>
                            <option value="Support Staff">Support Staff</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="filterStatus">Status</label>
                        <select id="filterStatus">
                            <option value="">All Status</option>
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                </div>
                <div class="filter-actions">
                    <button class="btn-filter" onclick="applyFilters()">Apply Filters</button>
                    <button class="btn-clear" onclick="clearFilters()">Clear Filters</button>
                </div>
            </div>
            
            <!-- Action Bar -->
            <div class="action-bar no-print">
                <h2>Staff Members (<span id="staffCount">0</span>)</h2>
                <div class="action-buttons">
                    <button class="btn-add" onclick="openAddModal()">
                        ➕ Add New Staff
                    </button>
                    <button class="btn-report" onclick="generateReport()">
                        📄 Generate Report
                    </button>
                </div>
            </div>
            
            <!-- Staff Table -->
            <div class="table-container">
                <table class="staff-table" id="staffTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>NIC</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Salary (Rs.)</th>
                            <th>Join Date</th>
                            <th>Status</th>
                            <th class="no-print">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="staffTableBody">
                        <c:forEach var="staff" items="${staffList}">
                            <tr data-name="${staff.name}" data-role="${staff.role}" data-status="${staff.active ? 'active' : 'inactive'}">
                                <td>${staff.staffId}</td>
                                <td><strong>${staff.name}</strong></td>
                                <td>${staff.email}</td>
                                <td>${staff.nic}</td>
                                <td>${staff.phone}</td>
                                <td>${staff.role}</td>
                                <td>${staff.salary}.00</td>
                                <td>${staff.joinDate}</td>
                                <td>
                                    <span class="status-badge ${staff.active ? 'status-active' : 'status-inactive'}">
                                        ${staff.active ? 'Active' : 'Inactive'}
                                    </span>
                                </td>
                                <td class="no-print">
                                    <div class="table-actions">
                                        <button class="btn-edit" onclick="openEditModal(${staff.staffId}, '${staff.name}', '${staff.email}', '${staff.nic}', '${staff.phone}', '${staff.role}', ${staff.salary})">Edit</button>
                                        <button class="btn-delete" onclick="openDeleteModal(${staff.staffId}, '${staff.name}')">Delete</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty staffList}">
                            <tr id="noDataRow">
                                <td colspan="10" class="no-data">
                                    No staff members found. Click "Add New Staff" to get started.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
    
    <!-- Add Staff Modal -->
    <div id="addModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Add New Staff Member</h2>
                <span class="close" onclick="closeAddModal()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/admin/manage-staff" method="post">
                <div class="modal-body">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-group">
                        <label for="addName">Full Name *</label>
                        <input type="text" id="addName" name="name" placeholder="Enter full name" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="addEmail">Email Address *</label>
                        <input type="email" id="addEmail" name="email" placeholder="employee@company.com" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="addNic">NIC Number *</label>
                        <input type="text" id="addNic" name="nic" placeholder="123456789V" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="addPhone">Phone Number</label>
                        <input type="tel" id="addPhone" name="phone" placeholder="+94 77 123 4567">
                    </div>
                    
                    <div class="form-group">
                        <label for="addRole">Role *</label>
                        <select id="addRole" name="staffRole" required>
                            <option value="">Select Role</option>
                            <option value="Manager">Manager</option>
                            <option value="Supervisor">Supervisor</option>
                            <option value="Developer">Developer</option>
                            <option value="Designer">Designer</option>
                            <option value="Accountant">Accountant</option>
                            <option value="HR Officer">HR Officer</option>
                            <option value="Sales Executive">Sales Executive</option>
                            <option value="Support Staff">Support Staff</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="addSalary">Monthly Salary (Rs.) *</label>
                        <input type="number" id="addSalary" name="salary" placeholder="50000.00" step="0.01" min="0" required>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn-cancel" onclick="closeAddModal()">Cancel</button>
                    <button type="submit" class="btn-submit">Add Staff Member</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Edit Staff Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Staff Member</h2>
                <span class="close" onclick="closeEditModal()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/admin/manage-staff" method="post">
                <div class="modal-body">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" id="editStaffId" name="staffId">
                    
                    <div class="form-group">
                        <label for="editName">Full Name *</label>
                        <input type="text" id="editName" name="name" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editEmail">Email Address *</label>
                        <input type="email" id="editEmail" name="email" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editNic">NIC Number *</label>
                        <input type="text" id="editNic" name="nic" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editPhone">Phone Number</label>
                        <input type="tel" id="editPhone" name="phone">
                    </div>
                    
                    <div class="form-group">
                        <label for="editRole">Role *</label>
                        <select id="editRole" name="staffRole" required>
                            <option value="">Select Role</option>
                            <option value="Manager">Manager</option>
                            <option value="Supervisor">Supervisor</option>
                            <option value="Developer">Developer</option>
                            <option value="Designer">Designer</option>
                            <option value="Accountant">Accountant</option>
                            <option value="HR Officer">HR Officer</option>
                            <option value="Sales Executive">Sales Executive</option>
                            <option value="Support Staff">Support Staff</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="editSalary">Monthly Salary (Rs.) *</label>
                        <input type="number" id="editSalary" name="salary" step="0.01" min="0" required>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn-cancel" onclick="closeEditModal()">Cancel</button>
                    <button type="submit" class="btn-submit">Update Staff Member</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="modal-content delete-modal-content">
            <div class="modal-body">
                <div class="delete-icon">⚠️</div>
                <h2>Delete Staff Member?</h2>
                <p>Are you sure you want to permanently delete <span class="delete-staff-name" id="deleteStaffName"></span>?</p>
                <p class="warning-text">This action cannot be undone and will remove all associated data.</p>
                
                <div class="delete-actions">
                    <button class="btn-cancel-delete" onclick="closeDeleteModal()">Cancel</button>
                    <button class="btn-confirm-delete" onclick="confirmDelete()">Yes, Delete</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Hidden Delete Form -->
    <form id="deleteForm" action="${pageContext.request.contextPath}/admin/manage-staff" method="post" style="display: none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" id="deleteStaffId" name="staffId">
    </form>
    
    <script>
        let currentDeleteStaffId = null;
        
        // Initialize staff count
        document.addEventListener('DOMContentLoaded', function() {
            updateStaffCount();
        });
        
        // Add Modal Functions
        function openAddModal() {
            document.getElementById('addModal').style.display = 'block';
        }
        
        function closeAddModal() {
            document.getElementById('addModal').style.display = 'none';
            document.querySelector('#addModal form').reset();
        }
        
        // Edit Modal Functions
        function openEditModal(id, name, email, nic, phone, role, salary) {
            document.getElementById('editStaffId').value = id;
            document.getElementById('editName').value = name;
            document.getElementById('editEmail').value = email;
            document.getElementById('editNic').value = nic;
            document.getElementById('editPhone').value = phone;
            document.getElementById('editRole').value = role;
            document.getElementById('editSalary').value = salary;
            document.getElementById('editModal').style.display = 'block';
        }
        
        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
        }
        
        // Delete Modal Functions
        function openDeleteModal(staffId, staffName) {
            currentDeleteStaffId = staffId;
            document.getElementById('deleteStaffName').textContent = staffName;
            document.getElementById('deleteModal').style.display = 'block';
        }
        
        function closeDeleteModal() {
            document.getElementById('deleteModal').style.display = 'none';
            currentDeleteStaffId = null;
        }
        
        function confirmDelete() {
            if (currentDeleteStaffId) {
                document.getElementById('deleteStaffId').value = currentDeleteStaffId;
                document.getElementById('deleteForm').submit();
            }
        }
        
        // Filter Functions
        function applyFilters() {
            const nameFilter = document.getElementById('filterName').value.toLowerCase();
            const roleFilter = document.getElementById('filterRole').value;
            const statusFilter = document.getElementById('filterStatus').value;
            
            const rows = document.querySelectorAll('#staffTableBody tr');
            let visibleCount = 0;
            
            rows.forEach(row => {
                if (row.id === 'noDataRow') return;
                
                const name = row.getAttribute('data-name').toLowerCase();
                const role = row.getAttribute('data-role');
                const status = row.getAttribute('data-status');
                
                let showRow = true;
                
                if (nameFilter && !name.includes(nameFilter)) {
                    showRow = false;
                }
                
                if (roleFilter && role !== roleFilter) {
                    showRow = false;
                }
                
                if (statusFilter && status !== statusFilter) {
                    showRow = false;
                }
                
                row.style.display = showRow ? '' : 'none';
                if (showRow) visibleCount++;
            });
            
            document.getElementById('staffCount').textContent = visibleCount;
        }
        
        function clearFilters() {
            document.getElementById('filterName').value = '';
            document.getElementById('filterRole').value = '';
            document.getElementById('filterStatus').value = '';
            
            const rows = document.querySelectorAll('#staffTableBody tr');
            rows.forEach(row => {
                if (row.id !== 'noDataRow') {
                    row.style.display = '';
                }
            });
            
            updateStaffCount();
        }
        
        function updateStaffCount() {
            const rows = document.querySelectorAll('#staffTableBody tr');
            let count = 0;
            rows.forEach(row => {
                if (row.id !== 'noDataRow' && row.style.display !== 'none') {
                    count++;
                }
            });
            document.getElementById('staffCount').textContent = count;
        }
        
        // Generate Report Function
        function generateReport() {
            const originalTitle = document.title;
            document.title = 'SmartPayroll Staff Report - ' + new Date().toLocaleDateString();
            
            const reportHeader = document.createElement('div');
            reportHeader.innerHTML = `
                <div style="text-align: center; margin-bottom: 30px; page-break-after: avoid;">
                    <h1 style="margin: 0; color: #0f172a; font-size: 24px;">SmartPayroll Staff Management Report</h1>
                    <p style="margin: 10px 0; color: #64748b;">Generated on: ` + new Date().toLocaleString() + `</p>
                    <p style="margin: 5px 0; color: #64748b;">Total Staff Members: ` + document.getElementById('staffCount').textContent + `</p>
                    <hr style="border: none; border-top: 2px solid #e2e8f0; margin: 20px 0;">
                </div>
            `;
            
            const mainContent = document.querySelector('.main-content');
            mainContent.insertBefore(reportHeader, mainContent.firstChild);
            
            window.print();
            
            mainContent.removeChild(reportHeader);
            document.title = originalTitle;
        }
        
        // Close modals when clicking outside
        window.onclick = function(event) {
            const addModal = document.getElementById('addModal');
            const editModal = document.getElementById('editModal');
            const deleteModal = document.getElementById('deleteModal');
            
            if (event.target == addModal) {
                closeAddModal();
            }
            if (event.target == editModal) {
                closeEditModal();
            }
            if (event.target == deleteModal) {
                closeDeleteModal();
            }
        }
    </script>
</body>
</html>