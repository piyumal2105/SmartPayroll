<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartPayroll - Login</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            position: relative;
            overflow: hidden;
        }
        
        body::before {
            content: '';
            position: absolute;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(59, 130, 246, 0.15) 0%, transparent 70%);
            top: -150px;
            right: -150px;
            border-radius: 50%;
        }
        
        body::after {
            content: '';
            position: absolute;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(147, 51, 234, 0.15) 0%, transparent 70%);
            bottom: -100px;
            left: -100px;
            border-radius: 50%;
        }
        
        .login-container {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4);
            overflow: hidden;
            max-width: 1000px;
            width: 100%;
            display: grid;
            grid-template-columns: 45% 55%;
            position: relative;
            z-index: 1;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .login-banner {
            background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #6366f1 100%);
            padding: 60px 50px;
            color: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        
        .login-banner::before {
            content: '';
            position: absolute;
            width: 300px;
            height: 300px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            top: -100px;
            left: -100px;
        }
        
        .login-banner::after {
            content: '';
            position: absolute;
            width: 200px;
            height: 200px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            bottom: -50px;
            right: -50px;
        }
        
        .banner-content {
            position: relative;
            z-index: 1;
        }
        
        .logo-section {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 30px;
        }
        
        .logo-icon {
            width: 48px;
            height: 48px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            font-weight: bold;
            backdrop-filter: blur(10px);
        }
        
        .login-banner h1 {
            font-size: 2.8rem;
            margin-bottom: 20px;
            font-weight: 700;
            letter-spacing: -0.5px;
        }
        
        .login-banner p {
            font-size: 1.05rem;
            opacity: 0.95;
            line-height: 1.7;
            font-weight: 300;
        }
        
        .feature-list {
            margin-top: 35px;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .feature-item {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.95rem;
            opacity: 0.9;
        }
        
        .feature-icon {
            width: 24px;
            height: 24px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }
        
        .login-form-section {
            padding: 60px 50px;
            background: white;
        }
        
        .form-header {
            margin-bottom: 35px;
        }
        
        .form-header h2 {
            color: #0f172a;
            font-size: 2rem;
            margin-bottom: 8px;
            font-weight: 700;
        }
        
        .form-header p {
            color: #64748b;
            font-size: 0.95rem;
        }
        
        .role-tabs {
            display: flex;
            gap: 12px;
            margin-bottom: 32px;
            background: #f1f5f9;
            padding: 6px;
            border-radius: 12px;
        }
        
        .role-tab {
            flex: 1;
            padding: 12px;
            border: none;
            background: transparent;
            border-radius: 8px;
            cursor: pointer;
            text-align: center;
            font-weight: 600;
            color: #64748b;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            font-size: 0.95rem;
        }
        
        .role-tab:hover {
            color: #3b82f6;
        }
        
        .role-tab.active {
            background: white;
            color: #3b82f6;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }
        
        .form-group {
            margin-bottom: 24px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #334155;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .input-wrapper {
            position: relative;
        }
        
        .form-group input {
            width: 100%;
            padding: 13px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 0.95rem;
            transition: all 0.3s;
            background: #f8fafc;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #3b82f6;
            background: white;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
        }
        
        .submit-btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #3b82f6 0%, #6366f1 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 8px;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.4);
        }
        
        .submit-btn:active {
            transform: translateY(0);
        }
        
        .alert {
            padding: 14px 16px;
            border-radius: 10px;
            margin-bottom: 24px;
            font-size: 0.9rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-error {
            background: #fef2f2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }
        
        .alert-success {
            background: #f0fdf4;
            color: #16a34a;
            border: 1px solid #bbf7d0;
        }
        
        .alert::before {
            content: '●';
            font-size: 18px;
        }
        
        @media (max-width: 968px) {
            .login-container {
                grid-template-columns: 1fr;
                max-width: 480px;
            }
            
            .login-banner {
                padding: 40px 35px;
            }
            
            .login-banner h1 {
                font-size: 2.2rem;
            }
            
            .feature-list {
                display: none;
            }
            
            .login-form-section {
                padding: 40px 35px;
            }
        }
        
        @media (max-width: 480px) {
            body {
                padding: 15px;
            }
            
            .login-banner {
                padding: 30px 25px;
            }
            
            .login-form-section {
                padding: 30px 25px;
            }
            
            .form-header h2 {
                font-size: 1.6rem;
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-banner">
            <div class="banner-content">
                <div class="logo-section">
                    <div class="logo-icon">💼</div>
                    <h1>SmartPayroll</h1>
                </div>
                <p>Streamline your payroll operations with our comprehensive management solution. Handle employee data, track attendance, process payments, and manage leave requests effortlessly.</p>
                
                <div class="feature-list">
                    <div class="feature-item">
                        <div class="feature-icon">✓</div>
                        <span>Automated payroll processing</span>
                    </div>
                    <div class="feature-item">
                        <div class="feature-icon">✓</div>
                        <span>Real-time attendance tracking</span>
                    </div>
                    <div class="feature-item">
                        <div class="feature-icon">✓</div>
                        <span>Employee self-service portal</span>
                    </div>
                    <div class="feature-item">
                        <div class="feature-icon">✓</div>
                        <span>Comprehensive reporting</span>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="login-form-section">
            <div class="form-header">
                <h2>Welcome Back</h2>
                <p>Sign in to access your dashboard</p>
            </div>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert alert-success">
                    <%= request.getAttribute("success") %>
                </div>
            <% } %>
            
            <div class="role-tabs">
                <div class="role-tab active" id="adminTab" onclick="switchRole('ADMIN')">
                    Admin
                </div>
                <div class="role-tab" id="staffTab" onclick="switchRole('STAFF')">
                    Staff
                </div>
            </div>
            
            <form action="${pageContext.request.contextPath}/login" method="post">
                <input type="hidden" id="roleInput" name="role" value="ADMIN">
                
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <div class="input-wrapper">
                        <input type="email" id="email" name="email" 
                               placeholder="your.email@company.com"
                               value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" 
                               required>
                    </div>
                </div>
                
                <div class="form-group" id="nicGroup" style="display: none;">
                    <label for="nic">NIC Number</label>
                    <div class="input-wrapper">
                        <input type="text" id="nic" name="nic" 
                               placeholder="Enter your NIC number"
                               value="<%= request.getAttribute("nic") != null ? request.getAttribute("nic") : "" %>">
                    </div>
                </div>
                
                <div class="form-group" id="passwordGroup">
                    <label for="password">Password</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" 
                               placeholder="Enter your password"
                               required>
                    </div>
                </div>
                
                <button type="submit" class="submit-btn">Sign In</button>
            </form>
        </div>
    </div>
    
    <script>
        function switchRole(role) {
            const adminTab = document.getElementById('adminTab');
            const staffTab = document.getElementById('staffTab');
            
            if (role === 'ADMIN') {
                adminTab.classList.add('active');
                staffTab.classList.remove('active');
            } else {
                staffTab.classList.add('active');
                adminTab.classList.remove('active');
            }
            
            document.getElementById('roleInput').value = role;
            
            const nicGroup = document.getElementById('nicGroup');
            const nicInput = document.getElementById('nic');
            const passwordGroup = document.getElementById('passwordGroup');
            const passwordInput = document.getElementById('password');
            
            if (role === 'STAFF') {
                nicGroup.style.display = 'block';
                nicInput.required = true;
                passwordGroup.style.display = 'none';
                passwordInput.required = false;
                passwordInput.value = '';
            } else {
                nicGroup.style.display = 'none';
                nicInput.required = false;
                nicInput.value = '';
                passwordGroup.style.display = 'block';
                passwordInput.required = true;
            }
        }
    </script>
</body>
</html>