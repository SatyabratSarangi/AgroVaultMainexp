<%@ page import="java.sql.*, com.agrovault.DBConfig" %>
<%@ include file="components/nav.jsp" %>
<%
    // Ensure user is logged in AND is a FARMER
    if (sessionUserId == null || !"FARMER".equals(sessionRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String action = request.getParameter("action");
    int unitId = 0;
    if(request.getParameter("unitId") != null) {
        unitId = Integer.parseInt(request.getParameter("unitId"));
    }

    String msg = "";
    
    // Process Booking
    if ("book".equals(action)) {
        double tonsBooked = Double.parseDouble(request.getParameter("tons"));
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("INSERT INTO bookings (farmer_id, unit_id, tons_booked, status) VALUES (?, ?, ?, 'CONFIRMED')")) {
            pstmt.setInt(1, sessionUserId);
            pstmt.setInt(2, unitId);
            pstmt.setDouble(3, tonsBooked);
            pstmt.executeUpdate();
            
            // Redirect to a success view
            response.sendRedirect("booking.jsp?success=true&id=" + unitId);
            return;
        } catch (Exception e) {
            msg = "<div class='alert alert-error'>Booking Error: " + e.getMessage() + "</div>";
        }
    }
%>

<main class="container">
    <div class="header-section">
        <h1 class="page-title">Secure Your Storage</h1>
    </div>

    <% if ("true".equals(request.getParameter("success"))) { %>
        <div class="card" style="max-width: 600px; margin: 0 auto; text-align: center; padding: 4rem 2rem;">
            <svg style="color: var(--primary); width: 80px; height: 80px; margin-bottom: 1.5rem;" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <h2 style="color: var(--secondary); margin-bottom: 1rem;">Booking Confirmed!</h2>
            <p style="color: var(--text-muted); margin-bottom: 2rem;">Your storage has been successfully reserved. An E-Bill has been generated.</p>
            <a href="dashboard.jsp" class="btn btn-outline">Return to Dashboard</a>
        </div>
    <% } else { %>
        <%= msg %>
        
        <div class="form-card" style="max-width: 600px; margin: 0 auto;">
            <%
                try (Connection conn = DBConfig.getConnection();
                     PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM storage_units WHERE id = ?")) {
                    pstmt.setInt(1, unitId);
                    ResultSet rs = pstmt.executeQuery();
                    if(rs.next()) {
            %>
            <h2 style="margin-bottom: 0.5rem; color: var(--secondary);">Booking: <%= rs.getString("title") %></h2>
            <p style="color: var(--text-muted); margin-bottom: 2rem;">Rate: &#8377;<%= rs.getDouble("price") %> / Ton  |  Location: <%= rs.getString("city") %></p>
            
            <form method="post" action="booking.jsp">
                <input type="hidden" name="action" value="book">
                <input type="hidden" name="unitId" value="<%= unitId %>">
                
                <div class="form-group">
                    <label class="form-label">Tons Required</label>
                    <input type="number" step="0.01" max="<%= rs.getDouble("capacity") %>" name="tons" class="form-control" required placeholder="e.g. 5.5">
                    <small style="color: var(--text-muted); display: block; margin-top: 0.5rem;">Maximum available capacity: <%= rs.getDouble("capacity") %> Tons</small>
                </div>
                
                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">Confirm & Generate E-Bill</button>
            </form>
            <%
                    } else {
                        out.println("<p>Storage unit not found.</p>");
                    }
                } catch(Exception e) {
                     out.println("<p>System error.</p>");
                }
            %>
        </div>
    <% } %>
</main>

<%@ include file="components/footer.jsp" %>
