<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.User" %>
<%@ page import="com.smartpayroll.model.Attendance" %>
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
    <title>Attendance Management - SmartPayroll</title>
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
        
        .filter-group input {
            width: 100%;
            padding: 10px 14px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 0.9rem;
            transition: all 0.3s;
            background: #f8fafc;
        }
        
        .filter-group input:focus {
            outline: none;
            border-color: #3b82f6;
            background: white;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
        }
        
        .filter-divider {
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: #64748b;
            padding-bottom: 8px;
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
            text-decoration: none;
            display: inline-block;
            text-align: center;
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
        
        .attendance-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .attendance-table thead {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }
        
        .attendance-table th {
            padding: 16px;
            text-align: left;
            font-weight: 700;
            color: #0f172a;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .attendance-table td {
            padding: 16px;
            border-bottom: 1px solid #f1f5f9;
            color: #475569;
            font-size: 0.9rem;
        }
        
        .attendance-table tbody tr {
            transition: all 0.2s;
        }
        
        .attendance-table tbody tr:hover {
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
        
        .status-present {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #065f46;
        }
        
        .status-late {
            background: linear-gradient(135deg, #fed7aa 0%, #fbbf24 100%);
            color: #78350f;
        }
        
        .status-absent {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            color: #991b1b;
        }
        
        .status-half_day {
            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
            color: #1e40af;
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
            border-color: #3b82f6;
            background: white;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
        }
        
        .form-group input:read-only {
            background: #f1f5f9;
            color: #64748b;
            cursor: not-allowed;
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
            
            .attendance-table {
                font-size: 0.85rem;
            }
            
            .attendance-table th,
            .attendance-table td {
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
                    <li class="active">
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
                <h1>Attendance Management</h1>
                <p>Track and manage employee attendance records</p>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>
            
            <!-- Filter Section -->
            <div class="filter-card">
                <h3>Filter Attendance Records</h3>
                <form action="${pageContext.request.contextPath}/admin/attendance" method="get">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="filterDate">Specific Date</label>
                            <input type="date" id="filterDate" name="filterDate" value="${filterDate}">
                        </div>
                        
                        <div class="filter-divider">OR</div>
                        
                        <div class="filter-group">
                            <label for="startDate">From Date</label>
                            <input type="date" id="startDate" name="startDate" value="${startDate}">
                        </div>
                        
                        <div class="filter-group">
                            <label for="endDate">To Date</label>
                            <input type="date" id="endDate" name="endDate" value="${endDate}">
                        </div>
                        
                        <button type="submit" class="btn-filter">Apply Filter</button>
                        <a href="${pageContext.request.contextPath}/admin/attendance" class="btn-clear">Clear</a>
                    </div>
                </form>
            </div>
            
            <!-- Attendance Table -->
            <div class="table-container">
                <table class="attendance-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Staff Name</th>
                            <th>Email</th>
                            <th>Date</th>
                            <th>Check-In</th>
                            <th>Check-Out</th>
                            <th>Status</th>
                            <th>Notes</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty attendanceList}">
                                <c:forEach var="att" items="${attendanceList}">
                                    <tr>
                                        <td>${att.attendanceId}</td>
                                        <td><strong>${att.staffName}</strong></td>
                                        <td>${att.staffEmail}</td>
                                        <td>${att.attendanceDate}</td>
                                        <td>${att.checkInTime}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${att.checkOutTime != null}">
                                                    ${att.checkOutTime}
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #94a3b8;">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="status-badge status-${att.status.toLowerCase()}">
                                                ${att.status}
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${att.notes != null && !att.notes.isEmpty()}">
                                                    ${att.notes}
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #94a3b8;">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="table-actions">
                                                <button class="btn-edit" onclick="openEditModal(${att.attendanceId}, '${att.staffName}', '${att.attendanceDate}', '${att.checkInTime}', '${att.checkOutTime}', '${att.status}', '${att.notes}')">
                                                    Edit
                                                </button>
                                                <button class="btn-delete" onclick="openDeleteModal(${att.attendanceId}, '${att.staffName}', '${att.attendanceDate}')">
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
                                        No attendance records found for the selected filter
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
    
    <!-- Edit Modal -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Edit Attendance Record</h2>
                <span class="close" onclick="closeEditModal()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/admin/attendance" method="post">
                <div class="modal-body">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" id="editAttendanceId" name="attendanceId">
                    
                    <div class="form-group">
                        <label>Staff Name</label>
                        <input type="text" id="editStaffName" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>Date</label>
                        <input type="text" id="editDate" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="editCheckInTime">Check-In Time *</label>
                        <input type="time" id="editCheckInTime" name="checkInTime" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="editCheckOutTime">Check-Out Time</label>
                        <input type="time" id="editCheckOutTime" name="checkOutTime">
                    </div>
                    
                    <div class="form-group">
                        <label for="editStatus">Status *</label>
                        <select id="editStatus" name="status" required>
                            <option value="PRESENT">Present</option>
                            <option value="LATE">Late</option>
                            <option value="ABSENT">Absent</option>
                            <option value="HALF_DAY">Half Day</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="editNotes">Notes</label>
                        <textarea id="editNotes" name="notes" rows="3" placeholder="Add any additional notes"></textarea>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="button" class="btn-cancel" onclick="closeEditModal()">Cancel</button>
                    <button type="submit" class="btn-submit">Update Record</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="modal-content delete-modal-content">
            <div class="modal-body">
                <div class="delete-icon">⚠️</div>
                <h2>Delete Attendance Record?</h2>
                <p>Are you sure you want to delete attendance for <strong id="deleteStaffName"></strong> on <strong id="deleteDate"></strong>?</p>
                <p class="warning-text">This action cannot be undone.</p>
                
                <div class="delete-actions">
                    <button class="btn-cancel-delete" onclick="closeDeleteModal()">Cancel</button>
                    <button class="btn-confirm-delete" onclick="confirmDelete()">Yes, Delete</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Hidden Delete Form -->
    <form id="deleteForm" action="${pageContext.request.contextPath}/admin/attendance" method="post" style="display: none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" id="deleteAttendanceId" name="attendanceId">
    </form>
    
    <script>
        let currentDeleteId = null;
        
        // Edit Modal Functions
        function openEditModal(id, staffName, date, checkIn, checkOut, status, notes) {
            document.getElementById('editAttendanceId').value = id;
            document.getElementById('editStaffName').value = staffName;
            document.getElementById('editDate').value = date;
            
            // Format time values - remove seconds if present
            if (checkIn && checkIn !== 'null') {
                document.getElementById('editCheckInTime').value = checkIn.substring(0, 5);
            } else {
                document.getElementById('editCheckInTime').value = '';
            }
            
            if (checkOut && checkOut !== 'null') {
                document.getElementById('editCheckOutTime').value = checkOut.substring(0, 5);
            } else {
                document.getElementById('editCheckOutTime').value = '';
            }
            
            document.getElementById('editStatus').value = status;
            document.getElementById('editNotes').value = (notes == 'null' || !notes) ? '' : notes;
            document.getElementById('editModal').style.display = 'block';
        }
        
        function closeEditModal() {
            document.getElementById('editModal').style.display = 'none';
        }
        
        // Delete Modal Functions
        function openDeleteModal(id, staffName, date) {
            currentDeleteId = id;
            document.getElementById('deleteStaffName').textContent = staffName;
            document.getElementById('deleteDate').textContent = date;
            document.getElementById('deleteModal').style.display = 'block';
        }
        
        function closeDeleteModal() {
            document.getElementById('deleteModal').style.display = 'none';
            currentDeleteId = null;
        }
        
        function confirmDelete() {
            if (currentDeleteId) {
                document.getElementById('deleteAttendanceId').value = currentDeleteId;
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