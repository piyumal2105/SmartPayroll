<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.User" %>
<%@ page import="com.smartpayroll.model.Staff" %>
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
    <title>My Profile - SmartPayroll</title>
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
        
        /* Profile Card */
        .profile-card {
            background: white;
            border-radius: 16px;
            padding: 32px;
            margin-bottom: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .profile-header {
            display: flex;
            align-items: center;
            gap: 32px;
            margin-bottom: 32px;
            padding-bottom: 24px;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .profile-avatar {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            color: white;
            font-weight: 700;
            box-shadow: 0 8px 24px rgba(16, 185, 129, 0.3);
        }
        
        .profile-info h2 {
            font-size: 1.8rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 8px;
        }
        
        .profile-info p {
            color: #64748b;
            margin: 6px 0;
            font-size: 0.95rem;
        }
        
        .profile-badge {
            display: inline-block;
            padding: 8px 18px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-top: 8px;
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }
        
        .section-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #0f172a;
        }
        
        .btn-edit {
            padding: 10px 24px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: 600;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        
        .btn-edit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4);
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
        }
        
        .info-item {
            padding: 20px;
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border-radius: 12px;
            border-left: 4px solid #10b981;
            transition: all 0.3s;
        }
        
        .info-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }
        
        .info-label {
            font-size: 0.8rem;
            color: #64748b;
            font-weight: 600;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .info-value {
            font-size: 1.05rem;
            color: #0f172a;
            font-weight: 600;
        }
        
        .status-active {
            color: #10b981;
            font-weight: 700;
        }
        
        /* Edit Form */
        .edit-form {
            display: none;
        }
        
        .form-group {
            margin-bottom: 24px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #334155;
            font-size: 0.9rem;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 0.95rem;
            transition: all 0.3s;
            background: #f8fafc;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #10b981;
            background: white;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
        }
        
        .form-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 28px;
        }
        
        .btn-cancel {
            padding: 10px 24px;
            background: #f1f5f9;
            color: #475569;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: 600;
            transition: all 0.3s;
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
            
            .profile-header {
                flex-direction: column;
                text-align: center;
            }
            
            .profile-avatar {
                width: 100px;
                height: 100px;
                font-size: 2.5rem;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .section-header {
                flex-direction: column;
                gap: 16px;
                align-items: flex-start;
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
                    <li class="active">
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
                <h1>My Profile</h1>
                <p>View and manage your personal information</p>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>
            
            <!-- Profile Information View -->
            <div class="profile-card" id="profileView">
                <div class="profile-header">
                    <div class="profile-avatar">
                        ${staff.name.substring(0, 1).toUpperCase()}
                    </div>
                    <div class="profile-info">
                        <h2>${staff.name}</h2>
                        <p>${staff.email}</p>
                        <span class="profile-badge">${staff.role}</span>
                    </div>
                </div>
                
                <div class="section-header">
                    <h3 class="section-title">Personal Information</h3>
                    <button class="btn-edit" onclick="toggleEditMode()">Edit Profile</button>
                </div>
                
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Staff ID</div>
                        <div class="info-value">#${staff.staffId}</div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-label">Full Name</div>
                        <div class="info-value">${staff.name}</div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-label">Email Address</div>
                        <div class="info-value">${staff.email}</div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-label">NIC Number</div>
                        <div class="info-value">${staff.nic}</div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-label">Phone Number</div>
                        <div class="info-value">${staff.phone}</div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-label">Job Role</div>
                        <div class="info-value">${staff.role}</div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-label">Monthly Salary</div>
                        <div class="info-value">Rs. ${String.format("%,.2f", staff.salary)}</div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-label">Join Date</div>
                        <div class="info-value">${staff.joinDate}</div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-label">Account Status</div>
                        <div class="info-value status-active">● Active</div>
                    </div>
                </div>
            </div>
            
            <!-- Edit Form -->
            <div class="profile-card edit-form" id="profileEdit">
                <h3 class="section-title">Edit Profile Information</h3>
                <p style="color: #64748b; margin-bottom: 24px;">Update your contact information below</p>
                
                <form action="${pageContext.request.contextPath}/staff/profile" method="post">
                    <input type="hidden" name="action" value="update">
                    
                    <div class="form-group">
                        <label for="phone">Phone Number *</label>
                        <input type="tel" id="phone" name="phone" value="${staff.phone}" 
                               pattern="[0-9]{10}" placeholder="Enter 10-digit phone number" required>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn-cancel" onclick="toggleEditMode()">
                            Cancel
                        </button>
                        <button type="submit" class="btn-edit">
                            Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </main>
    </div>
    
    <script>
        function toggleEditMode() {
            const profileView = document.getElementById('profileView');
            const profileEdit = document.getElementById('profileEdit');
            
            if (profileView.style.display === 'none') {
                profileView.style.display = 'block';
                profileEdit.style.display = 'none';
            } else {
                profileView.style.display = 'none';
                profileEdit.style.display = 'block';
            }
        }
    </script>
</body>
</html>