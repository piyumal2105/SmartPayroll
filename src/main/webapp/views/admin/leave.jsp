<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.User" %>
<%@ page import="com.smartpayroll.model.Leave" %>
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
    <title>Leave Management - SmartPayroll</title>
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
        
        /* Statistics Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }
        
        .stat-card {
            background: white;
            padding: 28px;
            border-radius: 16px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
            position: relative;
            overflow: hidden;
            transition: all 0.3s;
        }
        
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            transition: width 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.08);
        }
        
        .stat-card:hover::before {
            width: 100%;
            opacity: 0.05;
        }
        
        .stat-card.pending::before {
            background: #f59e0b;
        }
        
        .stat-card.approved::before {
            background: #10b981;
        }
        
        .stat-card.rejected::before {
            background: #ef4444;
        }
        
        .stat-card.total::before {
            background: #3b82f6;
        }
        
        .stat-card h3 {
            font-size: 0.9rem;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        
        .stat-card .number {
            font-size: 2.5rem;
            font-weight: 700;
            line-height: 1;
        }
        
        .stat-card.pending .number {
            color: #f59e0b;
        }
        
        .stat-card.approved .number {
            color: #10b981;
        }
        
        .stat-card.rejected .number {
            color: #ef4444;
        }
        
        .stat-card.total .number {
            color: #3b82f6;
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
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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
        
        .leave-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .leave-table thead {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }
        
        .leave-table th {
            padding: 16px;
            text-align: left;
            font-weight: 700;
            color: #0f172a;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .leave-table td {
            padding: 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #475569;
            font-size: 0.9rem;
        }
        
        .leave-table tbody tr {
            transition: all 0.2s;
        }
        
        .leave-table tbody tr:hover {
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
        
        .status-approved {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #065f46;
        }
        
        .status-rejected {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            color: #991b1b;
        }
        
        .btn-approve, .btn-reject, .btn-view {
            padding: 8px 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
            margin-right: 6px;
        }
        
        .btn-approve {
            background: #d1fae5;
            color: #065f46;
        }
        
        .btn-approve:hover {
            background: #10b981;
            color: white;
            transform: translateY(-2px);
        }
        
        .btn-reject {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .btn-reject:hover {
            background: #ef4444;
            color: white;
            transform: translateY(-2px);
        }
        
        .btn-view {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .btn-view:hover {
            background: #3b82f6;
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
        
        .info-box {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            border: 2px solid #e2e8f0;
        }
        
        .info-box.success {
            background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
            border-color: #bbf7d0;
        }
        
        .info-box.danger {
            background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
            border-color: #fecaca;
        }
        
        .info-row {
            display: grid;
            grid-template-columns: 140px 1fr;
            padding: 10px 0;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            gap: 16px;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .info-label {
            font-weight: 700;
            color: #475569;
            font-size: 0.9rem;
        }
        
        .info-value {
            color: #0f172a;
            font-size: 0.9rem;
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
        
        .form-group textarea {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 0.95rem;
            transition: all 0.3s;
            background: #f8fafc;
            font-family: inherit;
            resize: vertical;
        }
        
        .form-group textarea:focus {
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
        
        .btn-submit.success {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        
        .btn-submit.success:hover {
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3);
        }
        
        .btn-submit.danger {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }
        
        .btn-submit.danger:hover {
            box-shadow: 0 8px 20px rgba(239, 68, 68, 0.3);
        }
        
        .btn-cancel {
            background: #f1f5f9;
            color: #475569;
        }
        
        .btn-cancel:hover {
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
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .filter-row {
                grid-template-columns: 1fr;
            }
            
            .leave-table {
                font-size: 0.85rem;
            }
            
            .leave-table th,
            .leave-table td {
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
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/payroll">
                            <span class="icon">💰</span>
                            <span>Payroll</span>
                        </a>
                    </li>
                    <li class="active">
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
                <h1>Leave Management</h1>
                <p>Review and manage employee leave requests</p>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>
            
            <!-- Statistics -->
            <div class="stats-grid">
                <div class="stat-card pending">
                    <h3>Pending Requests</h3>
                    <p class="number">${pendingCount != null ? pendingCount : 0}</p>
                </div>
                
                <div class="stat-card approved">
                    <h3>Approved</h3>
                    <p class="number">${approvedCount != null ? approvedCount : 0}</p>
                </div>
                
                <div class="stat-card rejected">
                    <h3>Rejected</h3>
                    <p class="number">${rejectedCount != null ? rejectedCount : 0}</p>
                </div>
                
                <div class="stat-card total">
                    <h3>Total Requests</h3>
                    <p class="number">${totalCount != null ? totalCount : 0}</p>
                </div>
            </div>
            
            <!-- Filter Section -->
            <div class="filter-card">
                <h3>Filter Leave Requests</h3>
                <form action="${pageContext.request.contextPath}/admin/leave" method="get">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="filterStatus">Status</label>
                            <select id="filterStatus" name="filterStatus">
                                <option value="">All Status</option>
                                <option value="PENDING" ${filterStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                                <option value="APPROVED" ${filterStatus == 'APPROVED' ? 'selected' : ''}>Approved</option>
                                <option value="REJECTED" ${filterStatus == 'REJECTED' ? 'selected' : ''}>Rejected</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="filterType">Leave Type</label>
                            <select id="filterType" name="filterType">
                                <option value="">All Types</option>
                                <option value="SICK" ${filterType == 'SICK' ? 'selected' : ''}>Sick Leave</option>
                                <option value="CASUAL" ${filterType == 'CASUAL' ? 'selected' : ''}>Casual Leave</option>
                                <option value="ANNUAL" ${filterType == 'ANNUAL' ? 'selected' : ''}>Annual Leave</option>
                                <option value="EMERGENCY" ${filterType == 'EMERGENCY' ? 'selected' : ''}>Emergency</option>
                                <option value="OTHER" ${filterType == 'OTHER' ? 'selected' : ''}>Other</option>
                            </select>
                        </div>
                        
                        <button type="submit" class="btn-filter">Apply Filter</button>
                        <a href="${pageContext.request.contextPath}/admin/leave" class="btn-clear">Clear</a>
                    </div>
                </form>
            </div>
            
            <!-- Leave Requests Table -->
            <div class="table-container">
                <table class="leave-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Staff Name</th>
                            <th>Leave Type</th>
                            <th>Start Date</th>
                            <th>End Date</th>
                            <th>Days</th>
                            <th>Reason</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty leaveList}">
                                <c:forEach var="leave" items="${leaveList}">
                                    <tr>
                                        <td>${leave.leaveId}</td>
                                        <td><strong>${leave.staffName}</strong></td>
                                        <td>${leave.leaveType}</td>
                                        <td>${leave.startDate}</td>
                                        <td>${leave.endDate}</td>
                                        <td>${leave.durationDays}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${leave.reason.length() > 50}">
                                                    ${leave.reason.substring(0, 50)}...
                                                </c:when>
                                                <c:otherwise>
                                                    ${leave.reason}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="status-badge status-${leave.status.toLowerCase()}">
                                                ${leave.status}
                                            </span>
                                        </td>
                                        <td>
                                            <c:if test="${leave.status == 'PENDING'}">
                                                <button class="btn-approve" 
                                                        onclick="openApproveModal(${leave.leaveId}, '${leave.staffName}', '${leave.leaveType}', '${leave.startDate}', '${leave.endDate}', ${leave.durationDays}, '${leave.reason}')">
                                                    Approve
                                                </button>
                                                <button class="btn-reject" 
                                                        onclick="openRejectModal(${leave.leaveId}, '${leave.staffName}', '${leave.leaveType}', '${leave.startDate}', '${leave.endDate}')">
                                                    Reject
                                                </button>
                                            </c:if>
                                            <c:if test="${leave.status != 'PENDING'}">
                                                <button class="btn-view" 
                                                        onclick="viewDetails(${leave.leaveId}, '${leave.staffName}', '${leave.leaveType}', '${leave.startDate}', '${leave.endDate}', ${leave.durationDays}, '${leave.reason}', '${leave.status}', '${leave.remarks}', '${leave.approvedDate}')">
                                                    View Details
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9" class="no-data">
                                        No leave requests found for the selected filter
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
    
    <!-- Approve Modal -->
    <div id="approveModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Approve Leave Request</h2>
                <span class="close" onclick="closeApproveModal()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/admin/leave" method="post">
                <div class="modal-body">
                    <input type="hidden" name="action" value="approve">
                    <input type="hidden" id="approveLeaveId" name="leaveId">
                    
                    <div class="info-box success">
                        <div class="info-row">
                            <span class="info-label">Staff Name:</span>
                            <span class="info-value" id="approveStaffName"></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Leave Type:</span>
                            <span class="info-value" id="approveLeaveType"></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Duration:</span>
                            <span class="info-value" id="approveDuration"></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Reason:</span>
                            <span class="info-value" id="approveReason"></span>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="approveRemarks">Remarks (Optional)</label>
                        <textarea id="approveRemarks" name="remarks" rows="3" 
                                  placeholder="Add any comments or conditions for approval..."></textarea>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn-cancel" onclick="closeApproveModal()">Cancel</button>
                    <button type="submit" class="btn-submit success">Confirm Approval</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Reject Modal -->
    <div id="rejectModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Reject Leave Request</h2>
                <span class="close" onclick="closeRejectModal()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/admin/leave" method="post">
                <div class="modal-body">
                    <input type="hidden" name="action" value="reject">
                    <input type="hidden" id="rejectLeaveId" name="leaveId">
                    
                    <div class="info-box danger">
                        <div class="info-row">
                            <span class="info-label">Staff Name:</span>
                            <span class="info-value" id="rejectStaffName"></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Leave Type:</span>
                            <span class="info-value" id="rejectLeaveType"></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Duration:</span>
                            <span class="info-value" id="rejectDuration"></span>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="rejectRemarks">Reason for Rejection *</label>
                        <textarea id="rejectRemarks" name="remarks" rows="4" required
                                  placeholder="Please provide a clear reason for rejecting this leave request..."></textarea>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn-cancel" onclick="closeRejectModal()">Cancel</button>
                    <button type="submit" class="btn-submit danger">Confirm Rejection</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- View Details Modal -->
    <div id="viewModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Leave Request Details</h2>
                <span class="close" onclick="closeViewModal()">&times;</span>
            </div>
            <div class="modal-body">
                <div class="info-box">
                    <div class="info-row">
                        <span class="info-label">Staff Name:</span>
                        <span class="info-value" id="viewStaffName"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Leave Type:</span>
                        <span class="info-value" id="viewLeaveType"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Start Date:</span>
                        <span class="info-value" id="viewStartDate"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">End Date:</span>
                        <span class="info-value" id="viewEndDate"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Duration:</span>
                        <span class="info-value" id="viewDuration"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Reason:</span>
                        <span class="info-value" id="viewReason"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Status:</span>
                        <span class="info-value" id="viewStatus"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Approved Date:</span>
                        <span class="info-value" id="viewApprovedDate"></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Remarks:</span>
                        <span class="info-value" id="viewRemarks"></span>
                    </div>
                </div>
            </div>
            
            <div class="form-actions">
                <button class="btn-submit" onclick="closeViewModal()">Close</button>
            </div>
        </div>
    </div>
    
    <script>
        // Approve Modal Functions
        function openApproveModal(id, staffName, leaveType, startDate, endDate, days, reason) {
            document.getElementById('approveLeaveId').value = id;
            document.getElementById('approveStaffName').textContent = staffName;
            document.getElementById('approveLeaveType').textContent = leaveType;
            document.getElementById('approveDuration').textContent = startDate + ' to ' + endDate + ' (' + days + ' days)';
            document.getElementById('approveReason').textContent = reason;
            document.getElementById('approveModal').style.display = 'block';
        }
        
        function closeApproveModal() {
            document.getElementById('approveModal').style.display = 'none';
            document.getElementById('approveRemarks').value = '';
        }
        
        // Reject Modal Functions
        function openRejectModal(id, staffName, leaveType, startDate, endDate) {
            document.getElementById('rejectLeaveId').value = id;
            document.getElementById('rejectStaffName').textContent = staffName;
            document.getElementById('rejectLeaveType').textContent = leaveType;
            document.getElementById('rejectDuration').textContent = startDate + ' to ' + endDate;
            document.getElementById('rejectModal').style.display = 'block';
        }
        
        function closeRejectModal() {
            document.getElementById('rejectModal').style.display = 'none';
            document.getElementById('rejectRemarks').value = '';
        }
        
        // View Details Modal
        function viewDetails(id, staffName, leaveType, startDate, endDate, days, reason, status, remarks, approvedDate) {
            document.getElementById('viewStaffName').textContent = staffName;
            document.getElementById('viewLeaveType').textContent = leaveType;
            document.getElementById('viewStartDate').textContent = startDate;
            document.getElementById('viewEndDate').textContent = endDate;
            document.getElementById('viewDuration').textContent = days + ' days';
            document.getElementById('viewReason').textContent = reason;
            document.getElementById('viewStatus').textContent = status;
            document.getElementById('viewApprovedDate').textContent = (approvedDate && approvedDate !== 'null') ? approvedDate : '-';
            document.getElementById('viewRemarks').textContent = (remarks && remarks !== 'null') ? remarks : '-';
            document.getElementById('viewModal').style.display = 'block';
        }
        
        function closeViewModal() {
            document.getElementById('viewModal').style.display = 'none';
        }
        
        // Close modals when clicking outside
        window.onclick = function(event) {
            const approveModal = document.getElementById('approveModal');
            const rejectModal = document.getElementById('rejectModal');
            const viewModal = document.getElementById('viewModal');
            
            if (event.target == approveModal) {
                closeApproveModal();
            }
            if (event.target == rejectModal) {
                closeRejectModal();
            }
            if (event.target == viewModal) {
                closeViewModal();
            }
        }
    </script>
</body>
</html>