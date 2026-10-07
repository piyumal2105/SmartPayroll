<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    <title>Staff Dashboard - SmartPayroll</title>
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
        }
        
        .role-badge.staff {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
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
        
        .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
            padding-bottom: 24px;
            border-bottom: 1px solid #e2e8f0;
        }
        
        .content-header h1 {
            font-size: 2rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 4px;
        }
        
        .breadcrumb {
            color: #64748b;
            font-size: 0.9rem;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 12px 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }
        
        .user-avatar {
            width: 44px;
            height: 44px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
        }
        
        .user-name {
            font-weight: 600;
            color: #0f172a;
            font-size: 0.95rem;
        }
        
        .user-role {
            color: #64748b;
            font-size: 0.85rem;
        }
        
        /* Dashboard Stats */
        .dashboard-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }
        
        .stat-card {
            background: white;
            padding: 28px;
            border-radius: 16px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            display: flex;
            align-items: center;
            gap: 20px;
            transition: all 0.3s;
            border: 1px solid #f1f5f9;
            position: relative;
            overflow: hidden;
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
        
        .stat-card.blue::before {
            background: #3b82f6;
        }
        
        .stat-card.green::before {
            background: #10b981;
        }
        
        .stat-card.orange::before {
            background: #f59e0b;
        }
        
        .stat-card.purple::before {
            background: #8b5cf6;
        }
        
        .stat-icon {
            width: 64px;
            height: 64px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            flex-shrink: 0;
        }
        
        .stat-card.blue .stat-icon {
            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
        }
        
        .stat-card.green .stat-icon {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
        }
        
        .stat-card.orange .stat-icon {
            background: linear-gradient(135deg, #fed7aa 0%, #fbbf24 100%);
        }
        
        .stat-card.purple .stat-icon {
            background: linear-gradient(135deg, #ddd6fe 0%, #c4b5fd 100%);
        }
        
        .stat-details {
            flex: 1;
        }
        
        .stat-details h3 {
            font-size: 0.9rem;
            font-weight: 600;
            color: #64748b;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .stat-number {
            font-size: 2.2rem;
            font-weight: 700;
            color: #0f172a;
            line-height: 1;
            margin-bottom: 6px;
        }
        
        .stat-label {
            font-size: 0.85rem;
            color: #94a3b8;
        }
        
        /* Quick Actions */
        .quick-actions {
            background: white;
            padding: 28px;
            border-radius: 16px;
            margin-bottom: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .quick-actions h2 {
            font-size: 1.3rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 20px;
        }
        
        .action-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
        }
        
        .btn-action {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 16px 24px;
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            color: #334155;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s;
            border: 1px solid #e2e8f0;
            font-size: 0.95rem;
        }
        
        .btn-action:hover {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(16, 185, 129, 0.3);
            border-color: transparent;
        }
        
        .btn-action .icon {
            font-size: 1.2rem;
        }
        
        /* Recent Activity */
        .recent-activity {
            background: white;
            padding: 28px;
            border-radius: 16px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .recent-activity h2 {
            font-size: 1.3rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 20px;
        }
        
        .activity-list {
            display: flex;
            flex-direction: column;
            gap: 0;
        }
        
        .activity-item {
            padding: 16px;
            border-left: 4px solid #e2e8f0;
            background: #f8fafc;
            border-radius: 8px;
            margin-bottom: 12px;
            transition: all 0.3s;
        }
        
        .activity-item:hover {
            border-left-color: #10b981;
            background: #f0fdf4;
            transform: translateX(4px);
        }
        
        .activity-item .date {
            font-size: 0.85rem;
            color: #64748b;
            font-weight: 600;
            margin-bottom: 6px;
            display: block;
        }
        
        .activity-item .description {
            color: #475569;
            font-size: 0.9rem;
            line-height: 1.6;
        }
        
        .no-data {
            text-align: center;
            color: #94a3b8;
            padding: 48px 20px;
            font-style: italic;
            font-size: 0.95rem;
        }
        
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 16px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-left: 8px;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        
        .status-pending {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            color: #78350f;
        }
        
        .status-approved {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #065f46;
        }
        
        .status-present {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            color: #065f46;
        }
        
        .status-late {
            background: linear-gradient(135deg, #fed7aa 0%, #fbbf24 100%);
            color: #78350f;
        }
        
        .status-rejected {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            color: #991b1b;
        }
        
        /* Responsive */
        @media (max-width: 1024px) {
            .sidebar {
                width: 240px;
            }
            
            .main-content {
                margin-left: 240px;
            }
            
            .dashboard-stats {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        @media (max-width: 768px) {
            .sidebar {
                width: 70px;
            }
            
            .sidebar-header h2 {
                font-size: 1.5rem;
            }
            
            .sidebar-header h2 span:last-child,
            .sidebar-nav a span:not(.icon),
            .btn-logout span:not(.icon),
            .role-badge {
                display: none;
            }
            
            .sidebar-nav a,
            .btn-logout {
                justify-content: center;
            }
            
            .main-content {
                margin-left: 70px;
                padding: 20px;
            }
            
            .content-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
            }
            
            .dashboard-stats {
                grid-template-columns: 1fr;
            }
            
            .action-buttons {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 640px) {
            .sidebar {
                transform: translateX(-100%);
                transition: transform 0.3s;
            }
            
            .sidebar.mobile-open {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
            }
            
            .stat-card {
                padding: 20px;
            }
            
            .stat-icon {
                width: 52px;
                height: 52px;
                font-size: 1.6rem;
            }
            
            .stat-number {
                font-size: 1.8rem;
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
                    <li class="active">
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
                    <li>
                        <a href="${pageContext.request.contextPath}/staff/leave">
                            <span class="icon">🏖</span>
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
            <!-- Header -->
            <header class="content-header">
                <div>
                    <h1>Staff Dashboard</h1>
                    <p class="breadcrumb">Home / Dashboard</p>
                </div>
                <div class="user-info">
                    <span class="user-avatar">👤</span>
                    <div>
                        <p class="user-name">${staff.name}</p>
                        <p class="user-role">Staff Member</p>
                    </div>
                </div>
            </header>
            
            <!-- Dashboard Stats -->
            <div class="dashboard-stats">
                <div class="stat-card blue">
                    <div class="stat-icon">📅</div>
                    <div class="stat-details">
                        <h3>Attendance</h3>
                        <p class="stat-number">${attendanceDaysThisMonth != null ? attendanceDaysThisMonth : 0}</p>
                        <span class="stat-label">Days this month</span>
                    </div>
                </div>
                
                <div class="stat-card green">
                    <div class="stat-icon">🏖️</div>
                    <div class="stat-details">
                        <h3>Leave Balance</h3>
                        <p class="stat-number">${totalLeaveBalance != null ? totalLeaveBalance : 0}</p>
                        <span class="stat-label">Days remaining</span>
                    </div>
                </div>
                
                <div class="stat-card orange">
                    <div class="stat-icon">⏳</div>
                    <div class="stat-details">
                        <h3>Pending Leaves</h3>
                        <p class="stat-number">${pendingLeavesCount != null ? pendingLeavesCount : 0}</p>
                        <span class="stat-label">Awaiting approval</span>
                    </div>
                </div>
                
                <div class="stat-card purple">
                    <div class="stat-icon">💰</div>
                    <div class="stat-details">
                        <h3>Last Salary</h3>
                        <p class="stat-number">
                            Rs. <fmt:formatNumber value="${lastSalary != null ? lastSalary : 0}" pattern="#,##0" />
                        </p>
                        <span class="stat-label">Current month</span>
                    </div>
                </div>
            </div>
            
            <!-- Quick Actions -->
            <div class="quick-actions">
                <h2>Quick Actions</h2>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/staff/attendance" class="btn-action">
                        <span class="icon">✓</span> Mark Attendance
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/leave" class="btn-action">
                        <span class="icon">📝</span> Apply for Leave
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/payroll" class="btn-action">
                        <span class="icon">📄</span> View Payslip
                    </a>
                    <a href="${pageContext.request.contextPath}/staff/profile" class="btn-action">
                        <span class="icon">⚙️</span> Update Profile
                    </a>
                </div>
            </div>
            
            <!-- Recent Activity -->
            <div class="recent-activity">
                <h2>My Recent Activity</h2>
                <div class="activity-list">
                    <c:choose>
                        <c:when test="${not empty recentAttendance or not empty recentLeaves}">
                            <!-- Recent Attendance -->
                            <c:if test="${not empty recentAttendance}">
                                <c:forEach var="attendance" items="${recentAttendance}" begin="0" end="4">
                                    <div class="activity-item">
                                        <span class="date">${attendance.attendanceDate}</span>
                                        <div class="description">
                                            Attendance marked: Check-in at ${attendance.checkInTime}
                                            <c:if test="${attendance.checkOutTime != null}">
                                                , Check-out at ${attendance.checkOutTime}
                                            </c:if>
                                            <span class="status-badge status-${attendance.status.toLowerCase()}">
                                                ${attendance.status}
                                            </span>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:if>
                            
                            <!-- Recent Leave Requests -->
                            <c:if test="${not empty recentLeaves}">
                                <c:forEach var="leave" items="${recentLeaves}" begin="0" end="2">
                                    <div class="activity-item">
                                        <span class="date">${leave.startDate} - ${leave.endDate}</span>
                                        <div class="description">
                                            ${leave.leaveType} Leave Request (${leave.durationDays} days)
                                            <span class="status-badge status-${leave.status.toLowerCase()}">
                                                ${leave.status}
                                            </span>
                                            <c:if test="${not empty leave.remarks}">
                                                <br><small style="color: #64748b; margin-top: 4px; display: block;">Admin Note: ${leave.remarks}</small>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <p class="no-data">No recent activity to display</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </main>
    </div>
</body>
</html>