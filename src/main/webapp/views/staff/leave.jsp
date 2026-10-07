<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.User" %>
<%@ page import="com.smartpayroll.model.Leave" %>
<%@ page import="com.smartpayroll.model.LeaveBalance" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"STAFF".equals(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Leave - SmartPayroll</title>
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
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
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
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
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
        
        /* Balance Cards */
        .balance-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }
        
        .balance-card {
            background: white;
            padding: 28px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
            position: relative;
            overflow: hidden;
            transition: all 0.3s;
        }
        
        .balance-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
        }
        
        .balance-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.08);
        }
        
        .balance-card.sick::before {
            background: linear-gradient(135deg, #ec4899 0%, #be185d 100%);
        }
        
        .balance-card.casual::before {
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
        }
        
        .balance-card.annual::before {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        
        .balance-card.total::before {
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
        }
        
        .balance-card h3 {
            font-size: 0.85rem;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        
        .balance-card .days {
            font-size: 2.5rem;
            font-weight: 700;
            color: #0f172a;
            line-height: 1;
            margin-bottom: 8px;
        }
        
        .balance-card small {
            font-size: 0.85rem;
            color: #94a3b8;
        }
        
        /* Leave Card */
        .leave-card {
            background: white;
            border-radius: 16px;
            padding: 32px;
            margin-bottom: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .leave-card h2 {
            font-size: 1.3rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 24px;
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
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 0.95rem;
            transition: all 0.3s;
            background: #f8fafc;
            font-family: inherit;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #10b981;
            background: white;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
        }
        
        .form-group textarea {
            resize: vertical;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .btn-submit {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 14px 32px;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4);
        }
        
        /* Table Styles */
        .table-container {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
            margin-top: 24px;
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
        
        .btn-edit, .btn-delete {
            padding: 8px 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
            margin-right: 6px;
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
        
        .modal-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            padding: 24px 32px;
            border-top: 1px solid #f1f5f9;
        }
        
        .btn-cancel {
            background: #f1f5f9;
            color: #475569;
            padding: 12px 28px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s;
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
            
            .balance-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .form-row {
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
                <h2><span>💼</span> <span>SmartPayroll</span></h2>
                <p class="role-badge staff">Staff</p>
            </div>
            
            <nav class="sidebar-nav">
                <ul>
                    <li>
                        <a href="${pageContext.request.contextPath}/staff/dashboard">
                            <span class="icon">📊</span>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/staff/attendance">
                            <span class="icon">📅</span>
                            <span>My Attendance</span>
                        </a>
                    </li>
                    <li class="active">
                        <a href="${pageContext.request.contextPath}/staff/leave">
                            <span class="icon">🏖️</span>
                            <span>Apply Leave</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/staff/payroll">
                            <span class="icon">💰</span>
                            <span>View Payroll</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/staff/profile">
                            <span class="icon">👤</span>
                            <span>My Profile</span>
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
                <p>Apply for leave and track your leave balance</p>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>
            
            <!-- Leave Balance Cards -->
            <div class="balance-grid">
                <div class="balance-card sick">
                    <h3>Sick Leave</h3>
                    <p class="days">${leaveBalance.sickLeave != null ? leaveBalance.sickLeave : 0}</p>
                    <small>days remaining</small>
                </div>
                
                <div class="balance-card casual">
                    <h3>Casual Leave</h3>
                    <p class="days">${leaveBalance.casualLeave != null ? leaveBalance.casualLeave : 0}</p>
                    <small>days remaining</small>
                </div>
                
                <div class="balance-card annual">
                    <h3>Annual Leave</h3>
                    <p class="days">${leaveBalance.annualLeave != null ? leaveBalance.annualLeave : 0}</p>
                    <small>days remaining</small>
                </div>
                
                <div class="balance-card total">
                    <h3>Total Leave</h3>
                    <p class="days">${leaveBalance.totalLeave != null ? leaveBalance.totalLeave : 0}</p>
                    <small>days remaining</small>
                </div>
            </div>
            
            <!-- Apply for Leave -->
            <div class="leave-card">
                <h2>Apply for Leave</h2>
                <form action="${pageContext.request.contextPath}/staff/leave" method="post">
                    <input type="hidden" name="action" value="apply">
                    
                    <div class="form-group">
                        <label for="leaveType">Leave Type *</label>
                        <select id="leaveType" name="leaveType" required>
                            <option value="">Select Leave Type</option>
                            <option value="SICK">Sick Leave</option>
                            <option value="CASUAL">Casual Leave</option>
                            <option value="ANNUAL">Annual Leave</option>
                            <option value="EMERGENCY">Emergency Leave</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="startDate">Start Date *</label>
                            <input type="date" id="startDate" name="startDate" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="endDate">End Date *</label>
                            <input type="date" id="endDate" name="endDate" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="reason">Reason *</label>
                        <textarea id="reason" name="reason" rows="4" 
                                  placeholder="Please provide a detailed reason for your leave request..." required></textarea>
                    </div>
                    
                    <button type="submit" class="btn-submit">Submit Leave Request</button>
                </form>
            </div>
            
            <!-- Leave History -->
            <div class="leave-card">
                <h2>My Leave History</h2>
                
                <c:choose>
                    <c:when test="${not empty leaveList}">
                        <div class="table-container">
                            <table class="leave-table">
                                <thead>
                                    <tr>
                                        <th>Leave Type</th>
                                        <th>Start Date</th>
                                        <th>End Date</th>
                                        <th>Days</th>
                                        <th>Reason</th>
                                        <th>Status</th>
                                        <th>Remarks</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="leave" items="${leaveList}">
                                        <tr>
                                            <td><strong>${leave.leaveType}</strong></td>
                                            <td>${leave.startDate}</td>
                                            <td>${leave.endDate}</td>
                                            <td>${leave.durationDays}</td>
                                            <td>${leave.reason}</td>
                                            <td>
                                                <span class="status-badge status-${leave.status.toLowerCase()}">
                                                    ${leave.status}
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty leave.remarks}">
                                                        ${leave.remarks}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: #94a3b8;">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:if test="${leave.status == 'PENDING'}">
                                                    <button class="btn-edit" 
                                                            onclick="openEditModal(${leave.leaveId}, '${leave.leaveType}', '${leave.startDate}', '${leave.endDate}', '${leave.reason}')">
                                                        Edit
                                                    </button>
                                                    <button class="btn-delete" 
                                                            onclick="openDeleteModal(${leave.leaveId}, '${leave.startDate}', '${leave.endDate}')">
                                                        Delete
                                                    </button>
                                                </c:if>
                                                <c:if test="${leave.status != 'PENDING'}">
                                                    <span style="color: #94a3b8;">No actions</span>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="no-data">
                            No leave records found. Apply for your first leave above!
                        </p>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>
    
    <!-- Edit Leave Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Leave Request</h2>
                <span class="close" onclick="closeEditModal()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/staff/leave" method="post">
                <div class="modal-body">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" id="editLeaveId" name="leaveId">
                    
                    <div class="form-group">
                        <label for="editLeaveType">Leave Type *</label>
                        <select id="editLeaveType" name="leaveType" required>
                            <option value="SICK">Sick Leave</option>
                            <option value="CASUAL">Casual Leave</option>
                            <option value="ANNUAL">Annual Leave</option>
                            <option value="EMERGENCY">Emergency Leave</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="editStartDate">Start Date *</label>
                            <input type="date" id="editStartDate" name="startDate" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="editEndDate">End Date *</label>
                            <input type="date" id="editEndDate" name="endDate" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="editReason">Reason *</label>
                        <textarea id="editReason" name="reason" rows="4" required></textarea>
                    </div>
                </div>
                
                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeEditModal()">Cancel</button>
                    <button type="submit" class="btn-submit">Update Leave Request</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="modal-content delete-modal-content">
            <div class="modal-body">
                <div class="delete-icon">⚠️</div>
                <h2>Delete Leave Request?</h2>
                <p>Are you sure you want to delete this leave request from 
                <strong id="deleteStartDate"></strong> to <strong id="deleteEndDate"></strong>?</p>
                <p class="warning-text">This action cannot be undone.</p>
                
                <div class="delete-actions">
                    <button class="btn-cancel" onclick="closeDeleteModal()">Cancel</button>
                    <button class="btn-confirm-delete" onclick="confirmDelete()">Yes, Delete</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Hidden Delete Form -->
    <form id="deleteForm" action="${pageContext.request.contextPath}/staff/leave" method="post" style="display: none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" id="deleteLeaveId" name="leaveId">
    </form>
    
    <script>
        let currentDeleteId = null;
        
        // Set minimum date to today
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('startDate').min = today;
            document.getElementById('endDate').min = today;
        });
        
        // Update end date minimum when start date changes
        document.getElementById('startDate').addEventListener('change', function() {
            document.getElementById('endDate').min = this.value;
        });
        
        // Edit Modal Functions
        function openEditModal(id, type, startDate, endDate, reason) {
            document.getElementById('editLeaveId').value = id;
            document.getElementById('editLeaveType').value = type;
            document.getElementById('editStartDate').value = startDate;
            document.getElementById('editEndDate').value = endDate;
            document.getElementById('editReason').value = reason;
            
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('editStartDate').min = today;
            document.getElementById('editEndDate').min = today;
            
            document.getElementById('editModal').style.display = 'block';
        }
        
        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
        }
        
        // Update edit end date minimum when edit start date changes
        document.getElementById('editStartDate').addEventListener('change', function() {
            document.getElementById('editEndDate').min = this.value;
        });
        
        // Delete Modal Functions
        function openDeleteModal(id, startDate, endDate) {
            currentDeleteId = id;
            document.getElementById('deleteStartDate').textContent = startDate;
            document.getElementById('deleteEndDate').textContent = endDate;
            document.getElementById('deleteModal').style.display = 'block';
        }
        
        function closeDeleteModal() {
            document.getElementById('deleteModal').style.display = 'none';
            currentDeleteId = null;
        }
        
        function confirmDelete() {
            if (currentDeleteId) {
                document.getElementById('deleteLeaveId').value = currentDeleteId;
                document.getElementById('deleteForm').submit();
            }
        }
        
        // Close modals when clicking outside
        window.onclick = function(event) {
            const editModal = document.getElementById('editModal');
            const deleteModal = document.getElementById('deleteModal');
            
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