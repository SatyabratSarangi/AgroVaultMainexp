<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
<%
    String action = request.getParameter("action");
    String msg = "";
    
    if ("register".equals(action)) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String city = request.getParameter("city");
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("INSERT INTO users (name, email, password, role, city) VALUES (?, ?, ?, ?, ?)")) {
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setString(3, password);
            pstmt.setString(4, role);
            pstmt.setString(5, city);
            pstmt.executeUpdate();
            
            msg = "<div class='alert alert-success'>Registration successful! <a href='login.jsp'>Login here</a></div>";
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>Registration Error: " + e.getMessage() + "</div>";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - AgroVault</title>
    <link rel="stylesheet" href="css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { display: flex; align-items: center; justify-content: center; background: url('https://images.unsplash.com/photo-1500937386664-56d1dfef3854?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80') center/cover; padding: 2rem 0; }
        .overlay { position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.6); z-index: -1; }
    </style>
</head>
<body>
    <div class="overlay"></div>
    <div class="form-card" style="width: 100%; max-width: 500px; background: rgba(255,255,255,0.95); backdrop-filter: blur(10px);">
        <div style="text-align: center; margin-bottom: 2rem;">
            <a href="index.jsp" class="brand" style="font-size: 2.5rem;">AgroVault</a>
            <p style="color: var(--text-muted); margin-top: 0.5rem;">Create your account</p>
        </div>
        
        <%= msg %>
        
        <form method="post" action="register.jsp">
            <input type="hidden" name="action" value="register">
            
            <div class="form-group">
                <label class="form-label">Full Name</label>
                <input type="text" name="name" class="form-control" required placeholder="John Doe">
            </div>
            
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" class="form-control" required placeholder="john@example.com">
            </div>
            
            <div class="form-group">
                <label class="form-label">Password</label>
                <input type="password" name="password" class="form-control" required placeholder="Strong password">
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                <div class="form-group">
                    <label class="form-label">I am a...</label>
                    <select name="role" class="form-control" required>
                        <option value="FARMER">Farmer</option>
                        <option value="OWNER">Storage Owner</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">City</label>
                    <input type="text" name="city" class="form-control" required placeholder="e.g. Pune">
                </div>
            </div>
            
            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem; font-size: 1.1rem; padding: 0.8rem;">Create Account</button>
        </form>
        
        <div style="text-align: center; margin-top: 1.5rem; font-size: 0.9rem;">
            Already have an account? <a href="login.jsp" style="color: var(--primary); font-weight: 600; text-decoration: none;">Log in</a>
        </div>
    </div>
</body>
</html>
