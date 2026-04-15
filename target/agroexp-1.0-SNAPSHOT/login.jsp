<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
<%
    String action = request.getParameter("action");
    if ("logout".equals(action)) {
        session.invalidate();
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = "";
    
    if ("login".equals(action)) {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM users WHERE email = ? AND password = ?")) {
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("userName", rs.getString("name"));
                session.setAttribute("role", rs.getString("role"));
                session.setAttribute("city", rs.getString("city"));
                
                if ("OWNER".equals(rs.getString("role"))) {
                    response.sendRedirect("manage-listings.jsp");
                } else {
                    response.sendRedirect("dashboard.jsp");
                }
                return;
            } else {
                msg = "<div class='alert alert-error'>Invalid Email or Password!</div>";
            }
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>System Error: " + e.getMessage() + "</div>";
        }
    }
%>

<%-- Skip standard nav for login for cleaner look --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - AgroVault</title>
    <link rel="stylesheet" href="css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { display: flex; align-items: center; justify-content: center; background: url('https://images.unsplash.com/photo-1595841696677-6489ffa3f66c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80') center/cover; }
        .overlay { position: absolute; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.5); z-index: -1; }
    </style>
</head>
<body>
    <div class="overlay"></div>
    <div class="form-card" style="width: 100%; max-width: 400px; background: rgba(255,255,255,0.95); backdrop-filter: blur(10px);">
        <div style="text-align: center; margin-bottom: 2rem;">
            <a href="index.jsp" class="brand" style="font-size: 2.5rem;">AgroVault</a>
            <p style="color: var(--text-muted); margin-top: 0.5rem;">Welcome back</p>
        </div>
        
        <%= msg %>
        
        <form method="post" action="login.jsp">
            <input type="hidden" name="action" value="login">
            
            <div class="form-group">
                <label class="form-label">Email</label>
                <input type="email" name="email" class="form-control" required placeholder="Enter your email">
            </div>
            
            <div class="form-group">
                <label class="form-label">Password</label>
                <input type="password" name="password" class="form-control" required placeholder="Enter your password">
            </div>
            
            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem; font-size: 1.1rem; padding: 0.8rem;">Log In</button>
        </form>
        
        <div style="text-align: center; margin-top: 1.5rem; font-size: 0.9rem;">
            Don't have an account? <a href="register.jsp" style="color: var(--primary); font-weight: 600; text-decoration: none;">Sign up</a>
        </div>
    </div>
</body>
</html>
