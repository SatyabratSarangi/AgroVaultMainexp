<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
<%
    // Ensure user is logged in
    Integer userId = (Integer) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    
    if (userId == null || !"FARMER".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String unitIdStr = request.getParameter("unitId");
    String ratingStr = request.getParameter("rating");
    String comment = request.getParameter("comment");

    if (unitIdStr != null && ratingStr != null && comment != null) {
        try {
            int unitId = Integer.parseInt(unitIdStr);
            int rating = Integer.parseInt(ratingStr);

            try (Connection conn = DBConfig.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement("INSERT INTO reviews (unit_id, user_id, rating, comment) VALUES (?, ?, ?, ?)")) {
                pstmt.setInt(1, unitId);
                pstmt.setInt(2, userId);
                pstmt.setInt(3, rating);
                pstmt.setString(4, comment);
                pstmt.executeUpdate();
            }
            response.sendRedirect("dashboard.jsp");
        } catch (Exception e) {
            out.println("<div style='color:red;'>Error saving review: " + e.getMessage() + "</div>");
            out.println("<a href='dashboard.jsp'>Back to Dashboard</a>");
        }
    } else {
        response.sendRedirect("dashboard.jsp");
    }
%>
