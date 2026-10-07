<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.smartpayroll.model.User" %>
<%@ page import="com.smartpayroll.model.Payroll" %>
<%@ page import="com.smartpayroll.model.Staff" %>
<%@ page import="java.util.List" %>
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
    <title>My Payroll - SmartPayroll</title>
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
        
        /* Stats Grid */
        .stats-grid {
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
            width: 100%;
            height: 4px;
        }
        
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.08);
        }
        
        .stat-card.purple::before {
            background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
        }
        
        .stat-card.green::before {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        
        .stat-card.blue::before {
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
        }
        
        .stat-card.orange::before {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        
        .stat-card h3 {
            font-size: 0.85rem;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }
        
        .stat-card .amount {
            font-size: 2rem;
            font-weight: 700;
            color: #0f172a;
            line-height: 1;
        }
        
        /* Payroll Card */
        .payroll-card {
            background: white;
            border-radius: 16px;
            padding: 32px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            border: 1px solid #f1f5f9;
        }
        
        .payroll-card h2 {
            font-size: 1.3rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 24px;
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
        
        .btn-view {
            padding: 8px 16px;
            background: #dbeafe;
            color: #1e40af;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
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
            align-items: center;
            justify-content: center;
        }
        
        .modal-content {
            background: white;
            padding: 0;
            width: 90%;
            max-width: 600px;
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            max-height: 90vh;
            overflow-y: auto;
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
        
        .company-header {
            text-align: center;
            margin-bottom: 24px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e2e8f0;
        }
        
        .company-header h3 {
            font-size: 1.3rem;
            color: #0f172a;
            margin-bottom: 4px;
        }
        
        .company-header p {
            color: #64748b;
            font-size: 0.9rem;
        }
        
        .employee-info {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            padding: 16px;
            border-radius: 12px;
            margin-bottom: 24px;
        }
        
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }
        
        .detail-row:last-child {
            border-bottom: none;
        }
        
        .detail-label {
            font-weight: 600;
            color: #475569;
            font-size: 0.9rem;
        }
        
        .detail-value {
            color: #0f172a;
            font-size: 0.9rem;
        }
        
        .salary-breakdown {
            background: #f8fafc;
            padding: 20px;
            border-radius: 12px;
            border: 2px solid #e2e8f0;
        }
        
        .salary-breakdown h4 {
            font-size: 1rem;
            color: #0f172a;
            margin-bottom: 16px;
        }
        
        .breakdown-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            font-size: 0.95rem;
        }
        
        .breakdown-row.divider {
            padding-bottom: 12px;
            border-bottom: 2px solid #cbd5e0;
            margin-bottom: 12px;
        }
        
        .breakdown-row.total {
            border-top: 3px solid #10b981;
            padding-top: 16px;
            margin-top: 8px;
            font-weight: 700;
            font-size: 1.2rem;
            color: #0f172a;
        }
        
        .processed-info {
            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
            padding: 12px;
            border-radius: 8px;
            margin-top: 20px;
            text-align: center;
        }
        
        .processed-info small {
            color: #1e40af;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        .btn-download {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            margin-top: 20px;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        
        .btn-download:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4);
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
            
            .payroll-table {
                font-size: 0.85rem;
            }
            
            .payroll-table th,
            .payroll-table td {
                padding: 12px 8px;
            }
        }
        
        @media print {
            .sidebar, .page-header, .btn-download {
                display: none;
            }
            
            .main-content {
                margin: 0;
            }
            
            .modal-content {
                box-shadow: none;
                max-width: 100%;
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
                    <li class="active">
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
                <h1>My Payroll</h1>
                <p>View your salary details and payment history</p>
            </div>
            
            <c:if test="${not empty staff}">
                <!-- Salary Statistics -->
                <div class="stats-grid">
                    <div class="stat-card purple">
                        <h3>Monthly Salary</h3>
                        <p class="amount">Rs. <fmt:formatNumber value="${staff.salary != null ? staff.salary : 0}" pattern="#,##0"/></p>
                    </div>
                    
                    <div class="stat-card green">
                        <h3>Last Payment</h3>
                        <p class="amount">
                            <c:choose>
                                <c:when test="${not empty payrollList and payrollList.size() > 0}">
                                    Rs. <fmt:formatNumber value="${payrollList[0].netSalary}" pattern="#,##0"/>
                                </c:when>
                                <c:otherwise>
                                    Rs. 0
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    
                    <div class="stat-card blue">
                        <h3>YTD Earnings</h3>
                        <p class="amount">
                            <c:set var="ytdTotal" value="0"/>
                            <c:forEach var="payroll" items="${payrollList}">
                                <c:if test="${payroll.year == 2025}">
                                    <c:set var="ytdTotal" value="${ytdTotal + payroll.netSalary}"/>
                                </c:if>
                            </c:forEach>
                            Rs. <fmt:formatNumber value="${ytdTotal}" pattern="#,##0"/>
                        </p>
                    </div>
                    
                    <div class="stat-card orange">
                        <h3>Total Bonuses</h3>
                        <p class="amount">
                            <c:set var="bonusTotal" value="0"/>
                            <c:forEach var="payroll" items="${payrollList}">
                                <c:set var="bonusTotal" value="${bonusTotal + payroll.bonus}"/>
                            </c:forEach>
                            Rs. <fmt:formatNumber value="${bonusTotal}" pattern="#,##0"/>
                        </p>
                    </div>
                </div>
            </c:if>
            
            <!-- Payroll History -->
            <div class="payroll-card">
                <h2>Payment History</h2>
                
                <c:choose>
                    <c:when test="${not empty payrollList}">
                        <div class="table-container">
                            <table class="payroll-table">
                                <thead>
                                    <tr>
                                        <th>Month/Year</th>
                                        <th>Basic Salary</th>
                                        <th>Bonus</th>
                                        <th>Deductions</th>
                                        <th>Net Salary</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="payroll" items="${payrollList}">
                                        <tr>
                                            <td><strong>${payroll.month} ${payroll.year}</strong></td>
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
                                                <button class="btn-view" 
                                                        onclick="viewPayslip('${payroll.month}', ${payroll.year}, ${payroll.basicSalary}, ${payroll.bonus}, ${payroll.deductions}, ${payroll.netSalary}, '${payroll.status}', '${payroll.processedAt}')">
                                                    View Payslip
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="no-data">
                            No payroll records found. Your payroll will appear here once processed by HR.
                        </p>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>
    
    <!-- Payslip Modal -->
    <div id="payslipModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>Payslip Details</h2>
                <span class="close" onclick="closePayslipModal()">&times;</span>
            </div>
            
            <div class="modal-body">
                <div class="company-header">
                    <h3>SmartPayroll Corporation</h3>
                    <p>Salary Slip for <span id="payslipPeriod"></span></p>
                </div>
                
                <div class="employee-info">
                    <div class="detail-row">
                        <span class="detail-label">Employee:</span>
                        <span class="detail-value">${staff.name}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Employee ID:</span>
                        <span class="detail-value">${staff.staffId}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Role:</span>
                        <span class="detail-value">${staff.role}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Payment Status:</span>
                        <span id="payslipStatus"></span>
                    </div>
                </div>
                
                <div class="salary-breakdown">
                    <h4>Salary Breakdown</h4>
                    
                    <div class="breakdown-row">
                        <span>Basic Salary:</span>
                        <span id="payslipBasic">Rs. 0.00</span>
                    </div>
                    
                    <div class="breakdown-row divider">
                        <span>Bonus:</span>
                        <span id="payslipBonus" style="color: #10b981;">Rs. 0.00</span>
                    </div>
                    
                    <div class="breakdown-row">
                        <span><strong>Gross Salary:</strong></span>
                        <span id="payslipGross"><strong>Rs. 0.00</strong></span>
                    </div>
                    
                    <div class="breakdown-row">
                        <span>Deductions:</span>
                        <span id="payslipDeductions" style="color: #ef4444;">Rs. 0.00</span>
                    </div>
                    
                    <div class="breakdown-row total">
                        <span>Net Salary:</span>
                        <span id="payslipNet" style="color: #10b981;">Rs. 0.00</span>
                    </div>
                </div>
                
                <div class="processed-info">
                    <small><strong>Processed on:</strong> <span id="payslipProcessedDate">-</span></small>
                </div>
                
                <button class="btn-download" onclick="window.print()">
                    📄 Download Payslip
                </button>
            </div>
        </div>
    </div>
    
    <script>
        function viewPayslip(month, year, basic, bonus, deductions, net, status, processedDate) {
            document.getElementById('payslipPeriod').textContent = month + ' ' + year;
            
            const gross = parseFloat(basic) + parseFloat(bonus);
            
            document.getElementById('payslipBasic').textContent = 'Rs. ' + parseFloat(basic).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('payslipBonus').textContent = 'Rs. ' + parseFloat(bonus).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('payslipGross').textContent = 'Rs. ' + gross.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('payslipDeductions').textContent = 'Rs. ' + parseFloat(deductions).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('payslipNet').textContent = 'Rs. ' + parseFloat(net).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            
            const statusBadge = '<span class="status-badge status-' + status.toLowerCase() + '">' + status + '</span>';
            document.getElementById('payslipStatus').innerHTML = statusBadge;
            
            if (processedDate && processedDate !== 'null') {
                document.getElementById('payslipProcessedDate').textContent = new Date(processedDate).toLocaleDateString('en-US', { 
                    year: 'numeric', 
                    month: 'long', 
                    day: 'numeric' 
                });
            } else {
                document.getElementById('payslipProcessedDate').textContent = 'Pending Processing';
            }
            
            document.getElementById('payslipModal').style.display = 'flex';
        }
        
        function closePayslipModal() {
            document.getElementById('payslipModal').style.display = 'none';
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('payslipModal');
            if (event.target == modal) {
                closePayslipModal();
            }
        }
    </script>
</body>
</html>