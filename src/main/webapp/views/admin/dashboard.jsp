<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.User" %>
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
    <title>Admin Dashboard - SmartPayroll</title>
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
            line-height: 1.6;
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
        
        .logo-icon {
            font-size: 1.5rem;
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
        
        .role-badge.admin {
            background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%);
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
        
        /* Main Content Styles */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 32px;
            background: #f8fafc;
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
            background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%);
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
        
        /* Alert Styles */
        .alert {
            padding: 16px 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-size: 0.9rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .alert-error {
            background: #fef2f2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }
        
        .alert::before {
            content: '⚠';
            font-size: 1.2rem;
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
            background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(59, 130, 246, 0.3);
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
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            gap: 14px;
            transition: all 0.3s;
        }
        
        .activity-item:last-child {
            border-bottom: none;
        }
        
        .activity-item:hover {
            background: #f8fafc;
            border-radius: 8px;
        }
        
        .activity-icon {
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
        
        .activity-item p {
            margin: 0;
            color: #475569;
            font-size: 0.9rem;
            line-height: 1.5;
        }
        
        .no-data {
            text-align: center;
            color: #94a3b8;
            padding: 48px 20px;
            font-style: italic;
            font-size: 0.95rem;
        }
        
        /* Responsive Design */
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
            
            .sidebar-header p,
            .sidebar-nav a span:not(.icon),
            .btn-logout span:not(.icon) {
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
                <h2><span class="logo-icon">💼</span> <span>SmartPayroll</span></h2>
                <p class="role-badge admin">Admin</p>
            </div>
            
            <nav class="sidebar-nav">
                <ul>
                    <li class="active">
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
            <!-- Header -->
            <header class="content-header">
                <div>
                    <h1>Admin Dashboard</h1>
                    <p class="breadcrumb">Home / Dashboard</p>
                </div>
                <div class="user-info">
                    <span class="user-avatar">👤</span>
                    <div>
                        <p class="user-name"><%= user.getEmail() %></p>
                        <p class="user-role">Administrator</p>
                    </div>
                </div>
            </header>
            
            <!-- Error Message -->
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>
            
            <!-- Dashboard Stats -->
            <div class="dashboard-stats">
                <div class="stat-card blue">
                    <div class="stat-icon">👥</div>
                    <div class="stat-details">
                        <h3>Total Staff</h3>
                        <p class="stat-number">${totalStaff != null ? totalStaff : 0}</p>
                        <span class="stat-label">Active employees</span>
                    </div>
                </div>
                
                <div class="stat-card green">
                    <div class="stat-icon">✅</div>
                    <div class="stat-details">
                        <h3>Present Today</h3>
                        <p class="stat-number">${presentToday != null ? presentToday : 0}</p>
                        <span class="stat-label">Marked attendance</span>
                    </div>
                </div>
                
                <div class="stat-card orange">
                    <div class="stat-icon">📋</div>
                    <div class="stat-details">
                        <h3>Leave Requests</h3>
                        <p class="stat-number">${pendingLeaveRequests != null ? pendingLeaveRequests : 0}</p>
                        <span class="stat-label">Pending approval</span>
                    </div>
                </div>
                
                <div class="stat-card purple">
                    <div class="stat-icon">💰</div>
                    <div class="stat-details">
                        <h3>Payroll Status</h3>
                        <p class="stat-number">${processedPayroll != null ? processedPayroll : 0}</p>
                        <span class="stat-label">Processed this month</span>
                    </div>
                </div>
            </div>
            
            <!-- Quick Actions -->
            <div class="quick-actions">
                <h2>Quick Actions</h2>
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/admin/manage-staff" class="btn-action">
                        <span class="icon">➕</span> Add New Staff
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/attendance" class="btn-action">
                        <span class="icon">✓</span> Mark Attendance
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/payroll" class="btn-action">
                        <span class="icon">💵</span> Process Payroll
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/leave" class="btn-action">
                        <span class="icon">📄</span> View Leave Requests
                    </a>
                </div>
            </div>
            
            <!-- Recent Activity -->
            <div class="recent-activity">
                <h2>Recent Activity</h2>
                <div class="activity-list">
                    <c:choose>
                        <c:when test="${not empty recentActivity}">
                            <c:forEach var="activity" items="${recentActivity}">
                                <div class="activity-item">
                                    <span class="activity-icon">📌</span>
                                    <p>${activity}</p>
                                </div>
                            </c:forEach>
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