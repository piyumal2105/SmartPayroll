<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.User" %>
<%@ page import="com.smartpayroll.model.Attendance" %>
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
    <title>My Attendance - SmartPayroll</title>
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
        
        /* Attendance Card */
        .attendance-card {
            background: white;
            border-radius: 16px;
            padding: 32px;
            margin-bottom: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .attendance-card h2 {
            font-size: 1.3rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 24px;
        }
        
        .current-time {
            text-align: center;
            margin: 24px 0;
        }
        
        .current-time .date {
            font-size: 1rem;
            color: #64748b;
            margin-bottom: 12px;
        }
        
        .current-time .time {
            font-size: 2.5rem;
            font-weight: 700;
            color: #0f172a;
            font-variant-numeric: tabular-nums;
        }
        
        .check-in-section {
            text-align: center;
            margin: 32px 0;
        }
        
        .check-in-section p {
            color: #64748b;
            margin-bottom: 20px;
            font-size: 0.95rem;
        }
        
        .form-group {
            margin: 24px 0;
            text-align: left;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
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
            border-color: #10b981;
            background: white;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
        }
        
        .btn-checkin, .btn-checkout {
            padding: 16px 48px;
            font-size: 1.1rem;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s;
            margin-top: 20px;
        }
        
        .btn-checkin {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        
        .btn-checkin:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4);
        }
        
        .btn-checkout {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);
        }
        
        .btn-checkout:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(245, 158, 11, 0.4);
        }
        
        .btn-checkin:disabled, .btn-checkout:disabled {
            background: #e2e8f0;
            color: #94a3b8;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        .attendance-status {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 24px 0;
        }
        
        .status-item {
            text-align: center;
            padding: 24px;
            border-radius: 12px;
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border: 2px solid #e2e8f0;
        }
        
        .status-item h3 {
            font-size: 0.85rem;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        
        .status-item .value {
            font-size: 1.8rem;
            font-weight: 700;
            color: #0f172a;
        }
        
        .notes-display {
            margin: 24px 0;
            padding: 16px 20px;
            background: #f8fafc;
            border-left: 4px solid #10b981;
            border-radius: 8px;
        }
        
        .notes-display strong {
            color: #475569;
            display: block;
            margin-bottom: 8px;
        }
        
        .completion-message {
            text-align: center;
            color: #10b981;
            font-weight: 600;
            margin-top: 24px;
            padding: 16px;
            background: #f0fdf4;
            border-radius: 10px;
            border: 1px solid #bbf7d0;
        }
        
        /* Table Styles */
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
        
        .status-half-day {
            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
            color: #1e40af;
        }
        
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #94a3b8;
            font-size: 0.95rem;
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
            
            .attendance-card {
                padding: 24px;
            }
            
            .current-time .time {
                font-size: 2rem;
            }
            
            .attendance-status {
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
                    <li class="active">
                        <a href="${pageContext.request.contextPath}/staff/attendance">
                            <span class="icon">📅</span>
                            <span>My Attendance</span>
                        </a>
                    </li>
                    <li>
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
                <h1>My Attendance</h1>
                <p>Track and manage your attendance records</p>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>
            
            <!-- Today's Attendance Card -->
            <div class="attendance-card">
                <h2>Mark Today's Attendance</h2>
                
                <div class="current-time">
                    <div class="date" id="currentDate"></div>
                    <div class="time" id="currentTime"></div>
                </div>
                
                <c:choose>
                    <c:when test="${todayAttendance == null}">
                        <!-- Check In Form -->
                        <form action="${pageContext.request.contextPath}/staff/attendance" method="post">
                            <input type="hidden" name="action" value="checkin">
                            
                            <div class="check-in-section">
                                <p>You haven't checked in yet today. Please mark your attendance.</p>
                                
                                <div class="form-group">
                                    <label for="notes">Notes (Optional):</label>
                                    <textarea id="notes" name="notes" rows="3" 
                                              placeholder="Any notes about your attendance today..."></textarea>
                                </div>
                                
                                <button type="submit" class="btn-checkin">
                                    ✓ Check In Now
                                </button>
                            </div>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <!-- Attendance Status -->
                        <div class="attendance-status">
                            <div class="status-item">
                                <h3>Check-In Time</h3>
                                <div class="value">${todayAttendance.checkInTime}</div>
                            </div>
                            
                            <div class="status-item">
                                <h3>Check-Out Time</h3>
                                <div class="value">
                                    <c:choose>
                                        <c:when test="${todayAttendance.checkOutTime != null}">
                                            ${todayAttendance.checkOutTime}
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #94a3b8;">Not marked</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            
                            <div class="status-item">
                                <h3>Status</h3>
                                <div>
                                    <span class="status-badge status-${todayAttendance.status.toLowerCase()}">
                                        ${todayAttendance.status}
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <c:if test="${todayAttendance.notes != null && !todayAttendance.notes.isEmpty()}">
                            <div class="notes-display">
                                <strong>Notes:</strong>
                                ${todayAttendance.notes}
                            </div>
                        </c:if>
                        
                        <!-- Check Out Button -->
                        <c:if test="${todayAttendance.checkOutTime == null}">
                            <form action="${pageContext.request.contextPath}/staff/attendance" method="post" 
                                  style="text-align: center; margin-top: 24px;">
                                <input type="hidden" name="action" value="checkout">
                                <button type="submit" class="btn-checkout">
                                    ⏰ Check Out Now
                                </button>
                            </form>
                        </c:if>
                        
                        <c:if test="${todayAttendance.checkOutTime != null}">
                            <div class="completion-message">
                                ✓ You have completed your attendance for today. Great work!
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <!-- Attendance History -->
            <div class="attendance-card">
                <h2>Attendance History</h2>
                
                <c:choose>
                    <c:when test="${not empty attendanceHistory}">
                        <div class="table-container">
                            <table class="attendance-table">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Check-In</th>
                                        <th>Check-Out</th>
                                        <th>Status</th>
                                        <th>Notes</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="att" items="${attendanceHistory}">
                                        <tr>
                                            <td><strong>${att.attendanceDate}</strong></td>
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
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="no-data">
                            No attendance records found. Start by checking in today!
                        </p>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>
    
    <script>
        // Update current time
        function updateTime() {
            const now = new Date();
            const timeString = now.toLocaleTimeString('en-US', { 
                hour: '2-digit', 
                minute: '2-digit', 
                second: '2-digit',
                hour12: true
            });
            const dateString = now.toLocaleDateString('en-US', { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric' 
            });
            
            document.getElementById('currentDate').textContent = dateString;
            document.getElementById('currentTime').textContent = timeString;
        }
        
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html>