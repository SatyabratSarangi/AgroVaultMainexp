<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
<%
    // Standard session check
    Integer sessionUserId = (Integer) session.getAttribute("userId");
    String sessionRole = (String) session.getAttribute("role");
    String sessionUserName = (String) session.getAttribute("userName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AgroVault</title>
    <link rel="stylesheet" href="css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>

<nav class="navbar glass">
    <div class="nav-container">
        <a href="index.jsp" class="brand">AgroVault</a>
        <div class="nav-links">
            <% if (sessionUserId != null) { %>
                <span class="welcome-text">Welcome, <%= sessionUserName %></span>
                <% if ("FARMER".equals(sessionRole)) { %>
                    <a href="dashboard.jsp" class="nav-link">Find Storage</a>
                <% } else if ("OWNER".equals(sessionRole)) { %>
                    <a href="manage-listings.jsp" class="nav-link">My Listings</a>
                <% } %>
                <a href="support.jsp" class="nav-link">Support</a>
                <a href="login.jsp?action=logout" class="btn btn-outline">Logout</a>
            <% } else { %>
                <a href="login.jsp" class="nav-link">Login</a>
                <a href="register.jsp" class="btn btn-primary">Sign Up</a>
            <% } %>
        </div>
    </div>
</nav>
